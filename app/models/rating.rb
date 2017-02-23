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
    beer.update(rating: rating)
  end
end
