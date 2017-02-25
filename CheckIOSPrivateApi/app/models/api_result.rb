class ApiResult < ActiveRecord::Base
  serialize :result, JSON

  def self.search(category,keyword,user_name)
    if keyword && category && user_name 
      where(["user_name = '%s' and %s like '%s'", user_name, category,keyword])
    else
      where(["user_name = '%s'", user_name])
    end
  end

end
