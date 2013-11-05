require 'spec_helper'

describe 'Routing' do
  it 'routes root to movies#index' do
    expect(get: '/').to route_to('movies#index')
  end

  it 'routes :id to movies#show' do
    expect(get: '/1').to route_to(controller: 'movies', action: 'show', id: '1')
  end

  it 'routes :id/store to movies#store' do
    expect(get: '/1/store').to route_to(controller: 'movies', action: 'store', id: '1')
  end
end