class Rating < ApplicationRecord
  belongs_to :beer
  belongs_to :user
  validates_presence_of :value
  validates_presence_of :user_id
  validates_presence_of :beer_id
  before_commit :set_beer_rating, on: [:create, :update]

  def set_beer_rating
    if beer.ratings.count > 1
      rating = beer.ratings.average(:value).round(2)
    else
      rating = value
    end
    beer.update(average_rating: rating)
  end

  def self.create_with_relationships(user, beer, new_rating)
    user.beers << beer if user.beers.find_by(id: beer.id).nil?

    if new_rating.present?
      rating = beer.ratings.find_or_initialize_by(user_id: user.id)
      rating.value = new_rating
      rating.save
    end
  end
end
