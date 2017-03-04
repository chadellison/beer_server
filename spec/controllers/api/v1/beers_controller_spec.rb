require 'rails_helper'

RSpec.describe Api::V1::BeersController, type: :controller do
  describe "#index" do
    let(:type) { Faker::Name.name.downcase }

    context "when 'all beers' is in the params" do
      it "returns all the beers in reverse order" do
        5.times do
          name = Faker::Name.name.downcase
          Beer.create(name: name, beer_type: type, approved: true)
        end

        get :index, params: { type: "all types" }, format: :json

        expect(response.status).to eq 200
        parsed_response = JSON.parse(response.body)
        expect(parsed_response["beers"].count).to eq 5
        expect(parsed_response["beers"].first["name"]).to eq Beer.last.name
        expect(parsed_response["beers"].third["beer_type"]).to eq Beer.third.beer_type
      end
    end

    context "when there is a type specified in the parameters" do
      it "returns only beers with that type" do
        5.times do |n|
          type = "ipa" if n.even?
          name = Faker::Name.name
          Beer.create(name: name, beer_type: type, approved: true)
        end

        params = { type: "ipa"}

        get :index, params: params, format: :json

        parsed_response = JSON.parse(response.body)

        expect(response.status).to eq 200
        expect(parsed_response["beers"].count).to eq 3
        expect(parsed_response["beers"].all? { |beer| beer["beer_type"] == "ipa" }).to be true
      end
    end

    context "when there is a text param" do
      it "returns all of the beers that include those characters" do
        5.times do |n|
          type = Faker::Name.name.downcase
          name = n.to_s
          name += "abc" if n.even?
          Beer.create(name: name, beer_type: type, approved: true)
        end

        params = { type: "all types", text: "abc"}

        get :index, params: params, format: :json

        parsed_response = JSON.parse(response.body)

        expect(response.status).to eq 200
        expect(parsed_response["beers"].count).to eq 3
        expect(parsed_response["beers"].all? { |beer| beer["name"][1..-1] == "abc" }).to be true
      end
    end
  end

  describe "create" do
    let(:user) { User.create(first_name: Faker::Name.first_name,
                       last_name: Faker::Name.last_name,
                       email: Faker::Internet.email,
                       password: Faker::Internet.password,
                       approved: true)
    }

    context "with a valid beer and valid user" do
      it "returns the beer and a 201 status" do
        beer_name = Faker::Name.name
        params = { beer: { name: beer_name, beer_type: "ipa", rating: 3 },
                   token: user.password_digest }
        expect { post :create, params: params, format: :json }
          .to change { Beer.count }.by(1)

        expect(response.status).to eq 201
        expect(JSON.parse(response.body)["name"]).to eq beer_name.downcase
        expect(JSON.parse(response.body)["average_rating"]).to eq "3.0"
      end

      it "associates the user with the beer" do
        beer_name = Faker::Name.name
        params = { beer: { name: beer_name, beer_type: "ipa", rating: 3 },
                   token: user.password_digest }

        expect { post :create, params: params, format: :json }
          .to change { user.beers.count }.by(1)

        expect(user.beers.last.name).to eq beer_name.downcase
      end

      context "when the user has given a rating" do
        it "creates a rating" do
          beer_name = Faker::Name.name
          params = { beer: { name: beer_name, beer_type: "ipa", rating: 3 },
                     token: user.password_digest }

          expect { post :create, params: params, format: :json }
            .to change { Rating.count }.by(1)

          expect(user.beers.last.ratings.last).to eq Rating.last
        end
      end

      context "when no rating is given" do
        it "defaults to 0" do
          beer_name = Faker::Name.name
          params = { beer: { name: beer_name, beer_type: "ipa", rating: "" },
                     token: user.password_digest }

          expect { post :create, params: params, format: :json }
            .not_to change { Rating.count }

          expect(Beer.last.ratings).to eq []
          expect(Beer.last.average_rating).to eq 0.0
        end
      end
    end


    context "witn no token" do
      it "returns an error" do
        params = { beer: { name: Faker::Name.name, beer_type: "ipa" } }

        expect { post :create, params: params, format: :json }
          .to raise_exception(ActiveRecord::RecordNotFound)
      end
    end

    context "with an invalid beer creation" do
      it "returns a 422 and an error message" do
        params = { beer: { beer_type: "ipa" }, token: user.password_digest }
        post :create, params: params, format: :json

        expect(response.status).to eq 422
        error = { name: ["can't be blank"] }
        expect(JSON.parse(response.body).deep_symbolize_keys[:errors]).to eq error
      end
    end
  end

  context "private" do
    describe "find_or_initialize_beer" do
      xit "test" do
      end
    end
  end
end
