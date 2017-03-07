require 'rails_helper'

RSpec.describe Api::V1::AuthenticationController, type: :controller do
  describe "authenticate" do
    context "with the proper email and password" do
      let(:first_name) { Faker::Name.first_name }
      let(:last_name) { Faker::Name.last_name }
      let(:email) { Faker::Internet.email }
      let!(:user) { User.create(email: email,
                                password: "password",
                                first_name: first_name,
                                last_name: last_name,
                                approved: true) }
      let(:params) { { credentials: { email: email, password: "password" } } }

      it "returns the user's token" do
        post :create, params: params, format: :json

        expect(response.status).to eq 200
        expect(JSON.parse(response.body)["email"]).to eq email
        expect(JSON.parse(response.body)["password_digest"]).to be_present
      end
    end

    context "with improper credentials" do
      let(:email) { Faker::Internet.email }
      let!(:user) { User.create(email: email, password: "password") }
      let(:bad_password) { Faker::Name.name }
      let(:params) { { credentials: { email: email, password: bad_password } } }

      it "returns a 404 status and an error" do
        get :create, params: params, format: :json

        expect(response.status).to eq 404
        expect(JSON.parse(response.body)["password_digest"]).to be_nil
        expect(JSON.parse(response.body)["errors"]).to eq "Invalid Credentials"
      end
    end

    context "with an uppercase email" do
      let(:first_name) { Faker::Name.first_name }
      let(:last_name) { Faker::Name.last_name }
      let(:email) { Faker::Internet.email }
      let!(:user) { User.create(email: email,
                                password: "password",
                                first_name: first_name,
                                last_name: last_name,
                                approved: true) }

      let(:params) { { credentials: { email: email.upcase,
                                      password: "password" } } }

      it "finds the email regardless of case" do
        post :create, params: params, format: :json

        expect(response.status).to eq 200
        expect(JSON.parse(response.body)["email"]).to eq email
        expect(JSON.parse(response.body)["password_digest"]).to be_present
      end
    end
  end
end
