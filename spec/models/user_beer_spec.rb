require 'rails_helper'

RSpec.describe UserBeer, type: :model do
  it "belongs to a user" do
    user = User.create(email: Faker::Internet.email,
                       password: "password",
                       first_name: Faker::Name.first_name,
                       last_name: Faker::Name.last_name)

    user_beer = UserBeer.create(user_id: user.id)
    expect(user_beer.user).to eq user
  end

  it "belongs to a beer" do
    name = Faker::Name.name
    brand = Faker::Name.name
    beer = Beer.create(name: name, beer_type: "ipa", brand: brand)

    user_beer = UserBeer.create(beer_id: beer.id)
    expect(user_beer.beer).to eq beer
  end
end
