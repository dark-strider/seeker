require 'spec_helper'

describe MoviesController do
  context 'GET index' do
    it 'assigns @movies if search_param' do
      get :index, search: 'serenity'
      expect(assigns(:movies)).to be_a_kind_of(Array)
      expect(assigns(:movies).first).to be_a_kind_of(Hash)
      expect(assigns(:movies).first).to include(title: 'Serenity')
    end

    it 'assigns nil for @movies unless search_param' do
      get :index, search: ''
      expect(assigns(:movies)).to be_nil
    end

    it 'renders the index template' do
      get :index
      expect(response).to render_template(:index)
    end
  end

  describe 'GET show' do
    it 'assigns @movie' do
      get :show, id: 16320
      expect(assigns(:movie)).to be_an_instance_of(TheMovie)
      expect(assigns(:movie).name).to eq('Serenity')
    end

    context 'if @movie' do
      it 'renders the show template' do
        get :show, id: 16320
        expect(response).to render_template(:show)
      end
    end

    context 'unless @movie' do
      it 'sets a flash-alert message' do
        get :show, id: ''
        expect(flash[:alert]).to eq('Sorry... movie not found.')
      end

      it 'redirects to the root page' do
        get :show, id: ''
        expect(response).to redirect_to(:root)
      end
    end
  end

  describe 'GET store' do
    context 'if candidates' do
      it 'assigns @google(price) if seeking movie available in Google Store' do
        get :store, id: 16320, name: 'serenity', year: '2005'

        expect(assigns(:google)).to be_a_kind_of(Hash)
        expect(assigns(:google)[:url]).to include('https://play.google.com/store/movies/details?id=hxyciMFm7n8')
        expect(assigns(:google)[:price].present?).to be_true
        expect(assigns(:related)).to be_nil
      end

      it 'assigns @related movies if seeking movie not available in Google Store' do
        get :store, id: 16320, name: 'serenity'
        expect(assigns(:google)).to be_nil
        expect(assigns(:related).first).to be_a_kind_of(Hash)
        expect(assigns(:related).first).to include(name: 'Serenity')
      end
    end

    it 'not assign variables unless candidates' do
      get :store, id: 16320
      expect(assigns(:google)).to be_nil
      expect(assigns(:related)).to be_nil
    end

    it 'renders the _store' do
      get :store, id: 16320
      expect(response).to render_template(partial: '_store')
    end
  end

  describe 'REGEX' do
    let(:c) { MoviesController.new }

    context '#space' do
      it 'remove whitespaces before and after' do
        res = c.instance_eval{ space(' Serenity ') }
        expect(res).to eq('Serenity')
      end
    end

    context '#clear' do
      it 'downcase and remove non-word characters' do
        res = c.instance_eval{ clear('Fast & Furious.') }
        expect(res).to eq('fastfurious')
      end
    end

    context '#generic' do
      it "downcase and remove 'part num|iii'" do
        res_a = c.instance_eval{ generic('Back to the Future Part 2') }
        res_b = c.instance_eval{ generic('Back to the Future Part II') }
        expect(res_a).to eq(res_b)
        expect(res_a).to eq('back to the future ')
      end
    end

    context '#transformers' do
      it 'transform line for correct comparing' do
        res = c.instance_eval{ transformers(' The Batman: The Dark Knight, Part 1 & Part II') }
        expect(res).to eq('batmanthedarkknight1and2')
      end
    end
  end
end