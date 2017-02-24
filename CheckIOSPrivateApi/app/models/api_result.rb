class ApiResult < ActiveRecord::Base
  serialize :result, JSON

  def self.search(category,keyword,user_name)
    if keyword && category
      where(["user_name = '%s', '%s' = '%s'", user_name, category,keyword])
    else
      all 
    end
  end

end
