# beer model
class Beer < ApplicationRecord
  validates_presence_of :name, :beer_type, :brand
  validates_uniqueness_of :name
  has_many :user_beers
  has_many :users, through: :user_beers
  has_many :ratings

  scope :current_beers, (lambda do |beer, token = nil|
    if beer == 'my beers'
      Beer.joins(:users).where(users: { password_digest: token })
    else
      where(approved: true)
    end
  end)

  scope :beer_type, ->(type) { where(beer_type: type) }
  scope :beer_name, ->(text) { where('name LIKE ?', "%#{text.downcase}%") }

  scope :sort_by_criterion, (lambda do |criterion|
    case criterion
    when 'name' then order(:name)
    when 'rating' then order(average_rating: :desc)
    when 'abv' then order(abv: :desc)
    end
  end)

  scope :current_page, (->(page = 1, per_page = 24) { offset((page.to_i - 1) * per_page.to_i) })

  scope :beer_order, (-> { order(updated_at: :desc) })
  scope :beer_limit, (->(per_page) { limit(per_page) })

  def self.fetch_beer_types(params)
    current_beers(params[:current_beers], params[:token])
      .select(:beer_type)
      .distinct.pluck(:beer_type)
      .unshift('all types')
  end
end
