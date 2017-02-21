require 'rails_helper'

RSpec.describe User, type: :model do
  let(:email) { Faker::Internet.email }
  let(:password) { "password" }
  let(:first_name) { Faker::Name.first_name }
  let(:last_name) { Faker::Name.last_name }

  it "validates the presence of an email" do
    user = User.create(password: password,
                       first_name: first_name,
                       last_name: last_name)

    expect(user.valid?).to be false
    user.update(email: email)
    expect(user.valid?).to be true
  end

  it "validates the uniqueness of an email" do
    User.create(email: email,
                password: password,
                first_name: first_name,
                last_name: last_name)

    user = User.create(email: email,
                       password: password,
                       first_name: first_name,
                       last_name: last_name)

    expect(user.valid?).to be false
  end

  it "validates the presence of a password" do
    user = User.create(email: email, first_name: first_name, last_name: last_name)
    expect(user.valid?).to be false
    user.update(password: password)
    expect(user.valid?).to be true
  end

  it "validates the presence of a first_name" do
    user = User.create(email: email, password: password, last_name: last_name)
    expect(user.valid?).to be false
    user.update(first_name: first_name)
    expect(user.valid?).to be true
  end

  it "validates the presence of last_name" do
    user = User.create(email: email, password: password, first_name: first_name)
    expect(user.valid?).to be false
    user.update(last_name: last_name)
    expect(user.valid?).to be true
  end

  it "has many beers" do
    name = Faker::Name.name
    user = User.create(email: email,
                       password: password,
                       first_name: Faker::Name.first_name,
                       last_name: Faker::Name.last_name)

    user.beers.create(name: Faker::Name.name, beer_type: name)
    user.beers.create(name: Faker::Name.name, beer_type: name)
    expect(user.beers.count).to eq 2
  end
end
