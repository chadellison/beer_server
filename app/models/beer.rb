# beer model
class Beer < ApplicationRecord
  validates_presence_of :name, :beer_type, :brand
  validates_uniqueness_of :name
  has_many :user_beers
  has_many :users, through: :user_beers
  has_many :ratings

  scope :current_beers, (lambda do |beer, token = nil|
    if beer == 'my beers'
      User.find_by(password_digest: token).beers
    else
      where(approved: true)
    end
  end)

  scope :beer_type, (lambda do |type|
    where(beer_type: type) unless ['all types', ''].include?(type)
  end)

  scope :beer_name, (lambda do |text|
    where('name LIKE ?', "%#{text.downcase}%") if text.present?
  end)

  scope :sort_by_criterion, (lambda do |criterion|
    case criterion
    when 'name' then order(:name)
    when 'rating' then order(average_rating: :desc)
    when 'abv' then order(abv: :desc)
    end
  end)

  scope :current_page, (lambda do |page|
    offset((page.to_i - 1) * 24) if page.present?
  end)

  scope :beer_order, (-> { order(updated_at: :desc).limit(24) })

  def self.fetch_beer_types(params)
    current_beers(params[:current_beers], params[:token])
      .select(:beer_type)
      .distinct.pluck(:beer_type)
      .unshift('all types')
  end
end
