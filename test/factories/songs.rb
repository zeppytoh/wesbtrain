FactoryBot.define do
  factory :song do
    association :team
    title { "その日全世界が" }
    key { "A" }
    author { "長沢崇文" }
    body { "その日全世界が主の御名　高く掲げる　叫べ、王の王イエスに" } # TODO: コードを入れてシステムテストを行いたい。
    video_url { "MyString" } # TODO
  end
end
