class Check < ActiveRecord::Base
  belongs_to :word
  attr_accessible :newstat, :oldstat, :word_id

  scope :today, lambda{ where('created_at > ?', Time.now.beginning_of_day + 3.hours) }

  class << self
    def check_months
      checks = Check.find_by_sql('select date, sum(new) as new_count, count(date) as all_count
      from (
        select
          date(created_at) as date,
          case when oldstat=0 and newstat=1 then 1 else 0 end as new
        from checks
        order by created_at
      )
      group by date;
      ')
    end
  end
end
