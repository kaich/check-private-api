class ApiResult < ActiveRecord::Base
  serialize :result, JSON

  def self.search(category,keyword,user_name)
    if keyword && category && user_name 
      where(["user_name = '%s' and %s like '%s' and result IS NOT NULL", user_name, category,keyword])
    else
      where(["user_name = '%s' and result IS NOT NULL", user_name])
    end
  end

end
