FactoryBot.define do
  factory :song do
    association :team
    title { "MyString" }
    key { "MyString" }
    author { "MyString" }
    body { "MyText" }
    video_url { "MyString" }
  end
end
