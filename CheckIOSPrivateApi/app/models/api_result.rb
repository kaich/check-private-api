class ApiResult < ActiveRecord::Base
  serialize :result, JSON

  def self.search(category,keyword,user_name)
    debugger
    if keyword && category && user_name 
      where(["user_name = '%s' and '%s' like '%s'", user_name, category,keyword])
    else
      all 
    end
  end

end
