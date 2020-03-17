require 'rails_helper'

RSpec.describe 'Users API', type: :request do

  describe 'POST /signup' do
    it 'userを作成する' do
      valid_params = {'user_id': 'userid', 'password': 'password'}
      expect { post '/signup', params: { user: valid_params } }.to change(User, :count).by(+1)
      expect(response.status).to eq(200)
    end

    context 'userを作成する(エラー)' do
      it 'requiredエラー' do
        invalid_params = {'user_id': '', 'password': ''}
        expect { post '/signup', params: { user: invalid_params } }.to change(User, :count).by(+0)
        expect(response.status).to eq(400)
        # expect(response.body.cause).to eq('required user_id and password')
      end

      it 'lengthエラー(user_id短い)' do
        invalid_params = {'user_id': 'user', 'password': 'password'}
        expect { post '/signup', params: { user: invalid_params } }.to change(User, :count).by(+0)
        expect(response.status).to eq(400)
        # expect(response.body.cause).to eq('user_id should be more than 6 characters')
      end

      it 'lengthエラー(user_id長い)' do
        invalid_params = {'user_id': 'u' * 21, 'password': 'password'}
        expect { post '/signup', params: { user: invalid_params } }.to change(User, :count).by(+0)
        expect(response.status).to eq(400)
      end

      it 'lengthエラー(password短い)' do
        invalid_params = {'user_id': 'userid', 'password': 'passwor'}
        expect { post '/signup', params: { user: invalid_params } }.to change(User, :count).by(+0)
        expect(response.status).to eq(400)
      end

      it 'lengthエラー(password長い)' do
        invalid_params = {'user_id': 'userid', 'password': 'p' * 21}
        expect { post '/signup', params: { user: invalid_params } }.to change(User, :count).by(+0)
        expect(response.status).to eq(400)
      end

      it 'pattern正常(user_idに英数字,passwordに英数字記号)' do
        valid_params = {'user_id': 'userid3', 'password': 'password-{@}'}
        expect { post '/signup', params: { user: valid_params } }.to change(User, :count).by(+1)
        expect(response.status).to eq(200)
      end

      it 'patternエラー(user_idに記号)' do
        invalid_params = {'user_id': 'userid-:', 'password': 'password'}
        expect { post '/signup', params: { user: invalid_params } }.to change(User, :count).by(+0)
        expect(response.status).to eq(400)
      end

      it 'patternエラー(passwordに空白文字)' do
        invalid_params = {'user_id': 'userid', 'password': 'passwor d'}
        expect { post '/signup', params: { user: invalid_params } }.to change(User, :count).by(+0)
        expect(response.status).to eq(400)
      end


      it '既に同じuser_idを持つアカウントが存在している場合' do
        valid_params = {'user_id': 'userid', 'password': 'password'}
        dup_params = {'user_id': 'userid', 'password': 'password'}
        post '/signup', params: { user: valid_params }
        expect { post '/signup', params: { user: dup_params } }.to change(User, :count).by(+0)
        expect(response.status).to eq(400)
        # expect(response.body.cause).to eq('already same user_id is used')
      end
    end
  end

  describe 'GET /user/{user_id}' do
  end

  describe 'PATCH /user/{user_id}' do
  end

  describe 'POST /close' do
  end
end
