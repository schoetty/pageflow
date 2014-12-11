require 'spec_helper'

module Pageflow
  describe RobotsController do
    routes { Engine.routes }
    render_views

    describe '#show' do
      context 'with format text' do
        it 'responds with success' do
          get(:show, :format => 'text')

          expect(response.status).to eq(200)
        end

        it 'responds with disallow for published entry audio/video' do
          entry = create(:entry, :published)
          disallow_audio_path = "Disallow: #{short_audio_file_path(entry.to_model, '')}"
          disallow_video_path = "Disallow: #{short_video_file_path(entry.to_model, '')}"

          get(:show, :format => 'text')

          expect(response.body).to match(disallow_audio_path)
          expect(response.body).to match(disallow_video_path)
        end

        context 'with configured entry_request_scope' do
          before do
            Pageflow.config.public_entry_request_scope = lambda do |entries, request|
              entries.includes(:account).where(pageflow_accounts: {name: request.subdomain})
            end
          end

          it 'includes disallow for matching entry in response' do
            account = create(:account, :name => 'news')
            entry = create(:entry, :published, :account => account)
            disallow_audio_path = "Disallow: #{short_audio_file_path(entry.to_model, '')}"
            disallow_video_path = "Disallow: #{short_video_file_path(entry.to_model, '')}"

            request.host = 'news.example.com'
            get(:show, :format => 'text')

            expect(response.body).to match(disallow_audio_path)
            expect(response.body).to match(disallow_video_path)
          end

          it 'does not include disallow in response for non matching entry' do
            entry = create(:entry, :published)
            disallow_audio_path = "Disallow: #{short_audio_file_path(entry.to_model, '')}"
            disallow_video_path = "Disallow: #{short_video_file_path(entry.to_model, '')}"

            request.host = 'news.example.com'
            get(:show, :format => 'text')

            expect(response.body).not_to match(disallow_audio_path)
            expect(response.body).not_to match(disallow_video_path)
          end
        end
      end

      context 'with other known format' do
        it 'responds with not found' do
          get(:show, :format => 'html')

          expect(response.status).to eq(404)
        end
      end

      context 'with unknown format' do
        it 'responds with not found' do
          get(:show, :format => 'php')

          expect(response.status).to eq(404)
        end
      end
    end

  end
end
