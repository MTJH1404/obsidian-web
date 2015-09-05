require 'rails_helper'

RSpec.describe StudentsController, type: :controller do
	before :all do
		@school = create :school, :name => 'StudentsController'
		@a = create :school, :name => 'DifferentSchool'
		@b = create :student, :school => @school
		@c = create :student, :school => @a
	end

	before :each do
		allow(controller).to receive(:authenticate_from_token!)
		sign_in @school
	end

	after :each do
		sign_out @school
	end

	after :all do
		@c.destroy
		@b.destroy
		@a.destroy
		@school.destroy
	end

	it 'is able to GET index' do
		get :index
		expect(response).to have_http_status(:ok)
	end

	it 'automatically scopes index to the current school' do
		get :index
		body = JSON.parse(response.body)
		expect(body['data'].length).to eq(1)
		expect(body['data'][0]['id']).to eq(@b.id.to_s)
	end

	it 'is able to GET show' do
		get :show, :id => @b.id
		expect(response).to have_http_status(:ok)
	end

	it 'shows only authorised records' do
		get :show, :id => @c.id
		expect(response).to have_http_status(:not_found)
	end

	it 'is able to DELETE a record' do
		delete :destroy, :id => @b.id
		expect(response).to have_http_status(:no_content)
	end

	it 'destroys only authorised records' do
		delete :destroy, :id => @c.id
		expect(response).to have_http_status(:not_found)
	end
end
