class Beer < ApplicationRecord
  validates_presence_of :name, :beer_type, :brand
  validates_uniqueness_of :name
  has_many :user_beers
  has_many :users, through: :user_beers
  has_many :ratings

  scope :current_beers, -> (beer, token = nil) do
    if beer == "my beers"
      User.find_by(password_digest: token).beers
    else
      where(approved: true)
    end
  end

  scope :beer_type, -> (type) do
    where(beer_type: type) unless ["all types", ""].include?(type)
  end

  scope :beer_name, -> (text) do
    where("name LIKE ?", "%#{text.downcase}%") if text.present?
  end

  scope :sort_by_criterion, -> (criterion) do
    case criterion
    when "name" then order(:name)
    when "rating" then order(average_rating: :desc)
    when "abv" then order(abv: :desc)
    end
  end

  scope :current_page, -> (page) { offset((page.to_i - 1) * 24) if page.present? }
  scope :beer_order, -> { order(updated_at: :desc).limit(24) }

  # class << self
  #   def search(params)
  #     beers = scope_beers(params)
  #     beers = beers.where(beer_type: params["type"]) unless ["all types", ""].include?(params["type"])
  #     beers = check_text(params["text"], beers) if params["text"].present?
  #     beers = sort_by(beers, params["sort"]) if params["sort"].present?
  #     beers = calculate_offset(beers, params) if params[:page].present?
  #     beers = beers.order(updated_at: :desc).limit(24)
  #     beers
  #   end
  #
  #   def check_text(text, beers)
  #     beers.where("name LIKE ?", "%#{text.downcase}%")
  #   end
  #
  #   def scope_to_user(token)
  #     User.find_by(password_digest: token).beers
  #   end
  #
  #   def sort_by(beers, criterion)
  #     if criterion == "name"
  #       beers.order(:name)
  #     elsif criterion == "rating"
  #       beers.order(average_rating: :desc)
  #     elsif criterion == "abv"
  #       beers.order(abv: :desc)
  #     end
  #   end
  #
  #   def fetch_beer_types(params)
  #     scope_beers(params)
  #       .select(:beer_type)
  #       .distinct.pluck(:beer_type)
  #       .unshift("all types")
  #   end
  #
  #   def calculate_offset(beers, params)
  #     offset = (params[:page].to_i - 1) * 24
  #     beers.offset(offset)
  #   end
  #
  #   def scope_beers(params)
  #     if params["current_beers"] == "my beers"
  #       scope_to_user(params[:token])
  #     else
  #       Beer.where(approved: true)
  #     end
  #   end
  # end
end
