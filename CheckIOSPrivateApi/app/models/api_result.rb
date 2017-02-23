class ApiResult < ActiveRecord::Base
  serialize :result, JSON

  def self.search(search, user_name)
    if search
      where(['call_methods LIKE ? And user_name = ?', "%#{search}%", "%#{user_name}%"])
    else
      all 
    end
  end

end
