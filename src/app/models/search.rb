class Search < ApplicationRecord

  has_one :tr_paragraph
  belongs_to :transcription_xml
  searchkick  searchable: [:content, :entry],
              suggest: [:content],
              word_start: [:content, :entry],
              word_middle: [:content],
              word_end: [:content],
              highlight: [:content],
              settings: {index: {max_result_window: 100000}}

end
