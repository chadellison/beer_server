class Beer < ApplicationRecord
  validates_presence_of :name, :beer_type
  validates_uniqueness_of :name
  has_many :user_beers
  has_many :users, through: :user_beers

  class << self
    def search(params)
      beers = Beer.where(approved: true)
      beers = scope_to_user(params[:token]) if params["my_beers"].present?
      beers = beers.where(beer_type: params["type"]) unless params["type"] == "all beers"
      beers = check_text(params["text"], beers) if params["text"].present?
      beers = sort_by_rating(beers, params["sort"]) unless params["sort"] == "false"
      beers = beers.limit(50)
      beers
    end

    def check_text(text, beers)
      beers.where("name LIKE ?", "%#{text.downcase}%")
    end

    def scope_to_user(token)
      User.find_by(password_digest: token).beers
    end

    def sort_by_rating(beers, criterion)
      if criterion == "ascending"
        beers.order(:rating)
      else
        beers.order(rating: :desc)
      end
    end
  end
end
