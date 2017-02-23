require 'rails_helper'

RSpec.describe Beer, type: :model do
  let(:name) { Faker::Name.name }
  let(:type) { Faker::Name.name }

  it "should validate the name" do
    expect(Beer.new.valid?).to be false
    expect(Beer.new(name: name, beer_type: type).valid?).to be true
  end

  it "should validate the presence of a type" do
    expect(Beer.new(name: name).valid?).to be false
    expect(Beer.new(name: name, beer_type: type).valid?).to be true
  end

  it "should validate the uniqueness of the name" do
    beer1 = Beer.create(name: name, beer_type: type)
    beer2 = Beer.new(name: name, beer_type: type)
    expect(beer2.valid?).to be false
  end

  it "has many users" do
    first_name = Faker::Name.first_name
    last_name = Faker::Name.last_name
    email1 = Faker::Internet.email
    email2 = Faker::Internet.email
    password = Faker::Internet.password

    beer = Beer.create(name: Faker::Name.name, beer_type: Faker::Name.name)
    beer.users.create(email: email1,
                      password: password,
                      first_name: first_name,
                      last_name: last_name)

    beer.users.create(email: email2,
                      password: password,
                      first_name: first_name,
                      last_name: last_name)
    expect(beer.users.count).to eq 2
  end

  describe "search" do
    context "when beer type is 'all beers'" do
      before do
        5.times do
          Beer.create(name: Faker::Name.name,
                      beer_type: Faker::Name.name,
                      approved: true)
        end
      end

      it "returns all the beers" do
        expect(Beer.search("type" => "all types").count).to eq 5
      end
    end

    context "when the beer type is a different type" do
      before do
        5.times do |n|
          type = "ipa" if n.even?
          Beer.create(name: Faker::Name.name, beer_type: type, approved: true)
        end
      end

      it "returns only those types of beers" do
        expect(Beer.search("type" => "ipa").count).to eq 3
      end
    end

    context "when there are not 'text' params present" do
      it "does not call 'check_text'" do
        expect(Beer).not_to receive(:check_text)
        Beer.search({ "type" => "ipa" })
      end
    end

    context "when there are 'text' params present" do
      it "calls check_text" do
        name = Faker::Name.name
        expect(Beer).to receive(:check_text)
          .and_return(Beer)
        Beer.search({ "type" => "ipa", "text" => name })
      end
    end
  end

  describe "check_text" do
    it "does a search on beers that have the matching characters in the text" do
      beer = Beer.create(name: "jones", beer_type: "ipa")
      expect(Beer.check_text("one", Beer).last).to eq beer
    end
  end

  describe "sort_by_rating" do
    xit "test" do
    end
  end

  describe "fetch_beer_types" do
    xit "test" do
    end
  end

  describe "scope_to_user" do
    let(:email) { Faker::Internet.email }
    let(:user) {
      User.create(email: email,
                  password: "password",
                  first_name: Faker::Name.first_name,
                  last_name: Faker::Name.last_name)
    }

    before do
      5.times do |n|
        if n.even?
          user.beers.create(name: Faker::Name.name, beer_type: "ipa")
        end
      end
    end

    it "scopes the beers to a user by its password_digest" do
      expect(Beer.scope_to_user(user.password_digest)).to eq user.beers
    end
  end

  context "private" do
    describe "scope_beers" do
      xit "test" do
      end
    end
  end
end
