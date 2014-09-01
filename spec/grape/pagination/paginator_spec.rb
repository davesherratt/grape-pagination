require 'spec_helper'

describe Grape::Pagination::Paginator do
  let(:request      ) { double(Rack::Request, url: 'https://localhost:5000/api/v1/tweets?page=1&per_page=30') }
  let(:endpoint     ) { double(Grape::Endpoint, request: request, header: nil, params: Hashie::Mash.new(page: 1, per_page: 30)) }
  let(:collection   ) { double('collection', count: 4, paginate: nil) }
  subject(:paginator) { described_class.new endpoint, collection }

  describe '.paginate' do
    it 'sets the headers' do
      expect(endpoint).to receive(:header).with('Link', '<https://localhost:5000/api/v1/tweets?page=2&per_page=30>; rel="next"')
      paginator.paginate
    end

    it 'paginates the collection' do
      expect(collection).to receive(:paginate).with(page: 1, per_page: 30)
      paginator.paginate
    end

    it 'paginates with custom block' do
      expect(collection).to receive(:page).with(1).and_return(collection)
      expect(collection).to receive(:per).with(30)
      paginator.paginate do |col, params|
        col.page(params[:page]).per(params[:per_page])
      end
    end
  end
end
