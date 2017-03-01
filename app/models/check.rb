class Check < ActiveRecord::Base
  belongs_to :word
  attr_accessible :newstat, :oldstat, :word_id

  scope :today, lambda{ where('created_at > ?', Time.now.beginning_of_day + 3.hours) }

  class << self
    def check_days
      checks = Check.find_by_sql('select date, sum(new) as new_count,
        count(date) as all_count, sum(up) as up_count, sum(done) as done_count
      from (
        select
          date(created_at) as date,
          case when oldstat=0 and newstat=1 then 1 else 0 end as new,
          case when newstat=8 then 1 else 0 end as done,
          case when oldstat < newstat then 1 else 0 end as up
        from checks
        order by created_at
      )
      group by date
      order by date desc;
      ')
    end
  end
end
