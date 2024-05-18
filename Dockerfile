FROM ruby:3.3.1
WORKDIR /app
RUN gem install sinatra sinatra-contrib rackup puma jwt --no-document
COPY . /app
EXPOSE 4567
CMD ["ruby", "app.rb"]
