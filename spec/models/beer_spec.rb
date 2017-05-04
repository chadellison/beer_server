require 'rails_helper'

RSpec.describe Beer, type: :model do
  let(:name) { Faker::Name.name }
  let(:type) { Faker::Name.name }
  let(:brand) { Faker::Name.name }

  it "should validate the name" do
    expect(Beer.new(brand: brand, beer_type: type).valid?).to be false
    expect(Beer.new(name: name, beer_type: type, brand: brand).valid?).to be true
  end

  it "should validate the presence of a type" do
    expect(Beer.new(name: name, brand: brand).valid?).to be false
    expect(Beer.new(name: name, beer_type: type, brand: brand).valid?).to be true
  end

  it "should validate the presence of a brand" do
    expect(Beer.new(name: name, beer_type: "ipa").valid?).to be false
    expect(Beer.new(name: name, beer_type: type, brand: "avery").valid?).to be true
  end

  it "should validate the uniqueness of the name" do
    beer1 = Beer.create(name: name, beer_type: type, brand: brand)
    beer2 = Beer.new(name: name, beer_type: type, brand: brand)
    expect(beer2.valid?).to be false
  end

  xit "has many ratings" do
  end

  it "has many users" do
    first_name = Faker::Name.first_name
    last_name = Faker::Name.last_name
    email1 = Faker::Internet.email
    email2 = Faker::Internet.email
    password = Faker::Internet.password

    beer = Beer.create(name: name, beer_type: type, brand: brand)
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

  context "scopes" do
    let(:email) { Faker::Internet.email }
    let(:password) { Faker::Name.name }
    let(:first_name) { Faker::Name.first_name }
    let(:last_name) { Faker::Name.last_name }
    let(:user) do
      User.create(email: email, password: password,
                  first_name: first_name, last_name: last_name,
                  approved: true)
    end

    describe 'current_beers' do
      context "when 'my beers' is passed in" do
        before do
          5.times do
            user.beers.create(name: Faker::Name.name,
                              beer_type: Faker::Name.name,
                              brand: Faker::Name.name)
          end
        end

        it "returns all of a user's beers" do
          result = Beer.current_beers('my beers', user.password_digest)
          expect(result).to eq user.beers
          expect(result.count).to eq 5
        end
      end

      context "when 'my beers' is not passed in" do
        before do
          5.times do
            Beer.create(name: Faker::Name.name,
                        beer_type: Faker::Name.name,
                        brand: Faker::Name.name,
                        approved: true)

            Beer.create(name: Faker::Name.name,
                        beer_type: Faker::Name.name,
                        brand: Faker::Name.name)
          end
        end

        it 'returns all beers that have been approved' do
          result = Beer.where(approved: true)
          expect(Beer.current_beers('all beers')).to eq result

          expect(result.count).to eq 5
        end
      end
    end

    describe 'beer_type' do
      context 'when a specific beer type is passed in' do
        before do
          5.times do |n|
            type = 'ipa' if n.even?
            Beer.create(name: Faker::Name.name,
                        beer_type: type,
                        brand: brand,
                        approved: true)
          end
        end

        it 'returns only those types of beers' do
          expect(Beer.beer_type('ipa').count).to eq 3
        end
      end
    end

    describe 'beer_name' do
      context 'when the text does not match any beer names' do
        it 'no beers are returned' do
          text = 'fu'

          beer = Beer.create(name: 'bar', beer_type: 'ipa', brand: brand)
          expect(Beer.beer_name(text).last).to be_nil
        end
      end

      context 'when text is passed in' do
        it 'returns only beers with the specified text in their name' do
          text = Faker::Name.name.downcase

          beer = Beer.create(name: text, beer_type: 'ipa', brand: brand)
          expect(Beer.beer_name(text[1..-2]).last).to eq beer
        end
      end
    end

    describe 'sort_by_criterion' do
      context 'when name is passed in' do
        before do
          beer_names = %w[artistry other more_beer zzz rascal]

          5.times do
            Beer.create(name: beer_names.shuffle!.pop, beer_type: 'ipa',
                        brand: brand)
          end
        end

        it 'returns the beers sorted alphabetically' do
          result = %w[artistry more_beer other rascal zzz]
          expect(Beer.sort_by_criterion('name').map(&:name)).to eq result
        end
      end

      context 'when rating is passed in' do
        before do
          beer_ratings = %w[5 3 4 1 2]

          5.times do
            Beer.create(name: Faker::Name.name, beer_type: 'ipa',
                        brand: brand, average_rating: beer_ratings.shuffle!.pop)
          end
        end

        it 'reutrns the beers sorted by their average rating' do
          result = %w[5.0 4.0 3.0 2.0 1.0]
          expect(Beer.sort_by_criterion('rating')
            .map { |beer| beer.average_rating.to_s }).to eq result
        end
      end

      context 'when abv is passed in' do
        before do
          abvs = %w[9 10 8 6 4]

          5.times do
            Beer.create(name: Faker::Name.name, beer_type: 'ipa',
                        brand: brand, abv: abvs.shuffle!.pop)
          end
        end

        it 'returns the beers sorted by their abv' do
          result = [10, 9, 8, 6, 4]
          expect(Beer.sort_by_criterion('abv').map(&:abv)).to eq result
        end
      end
    end

    describe 'current_page' do
      context 'when page two and per_page 24 are passed in ' do
        it 'returns the next 24 beers starting on the 25th beer' do
          48.times do |n|
            name = if n == 24
                     'first beer'
                   elsif n == 47
                     'last beer'
                   else
                     n.to_s
                   end

            Beer.create(name: name, beer_type: 'ipa', brand: brand)
          end

          result = Beer.current_page('2', '24')

          expect(result.first.name).to eq 'first beer'
          expect(result.pluck(:name).last).to eq 'last beer'
          expect(result.count).to eq 24
        end
      end

      context 'when neither a page nor per_page are not passed in' do
        it 'returns all 48 beers' do
          48.times do |n|
            name = if n == 0
                     'first beer'
                   elsif n == 47
                     'last beer'
                   else
                     n.to_s
                   end

            Beer.create(name: name, beer_type: 'ipa', brand: brand)
          end

          result = Beer.current_page(nil, nil)
          expect(result.first.name).to eq 'first beer'
          expect(result.last.name).to eq 'last beer'
          expect(result.count).to eq 48
        end
      end
    end

    describe 'beer_order' do
      it 'returns the beers ordered by when they were last updated' do
        first = Beer.create(name: Faker::Name.name, beer_type: 'ipa',
                            brand: brand)
        second = Beer.create(name: Faker::Name.name, beer_type: 'ipa',
                             brand: brand)
        third = Beer.create(name: Faker::Name.name, beer_type: 'ipa',
                            brand: brand)

        first.update(name: 'first')

        expect(Beer.beer_order.to_a).to eq [first, third, second]
      end
    end
  end
end
