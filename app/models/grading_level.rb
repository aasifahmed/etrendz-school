# == Schema Information
#
# Table name: grading_levels
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  batch_id      :integer
#  min_score     :integer
#  order         :integer
#  is_deleted    :boolean          default(FALSE)
#  created_at    :datetime
#  updated_at    :datetime
#  credit_points :decimal(15, 2)
#  description   :string(255)
#

#Fedena
#Copyright 2011 Foradian Technologies Private Limited
#
#This product includes software developed at
#Project Fedena - http://www.projectfedena.org/
#
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#limitations under the License.

class GradingLevel < ActiveRecord::Base
  belongs_to :batch

  validates_presence_of :name, :min_score
  validates_presence_of :credit_points, :if=>:batch_has_gpa
  validates_uniqueness_of :name, :scope => [:batch_id, :is_deleted],:case_sensitive => false

  default_scope { order('min_score desc') }
  scope :default, -> { where(:batch_id => nil, :is_deleted => false)}
  scope :for_batch, ->(b) {  where(:batch_id => b.to_i, :is_deleted => false) } 

  def inactivate
    update_attribute :is_deleted, true
  end

  def batch_has_gpa
    self.batch_id and self.batch.gpa_enabled?
  end

  def to_s
    name
  end

 def self.exists_for_batch?(batch_id)
    batch_grades = GradingLevel.where(batch_id: batch_id, is_deleted: false)
    default_grade = GradingLevel.default
    if batch_grades.blank? and default_grade.blank?
      return false
    else
      return true
    end
  end

  class << self
    def percentage_to_grade(percent_score, batch_id)
      batch_grades = GradingLevel.for_batch(batch_id)
      if batch_grades.empty?
        grade = GradingLevel.default.where("min_score <= ?", percent_score.round).order('min_score desc').first
      else
        grade = GradingLevel.for_batch(batch_id).where("min_score <= ?", percent_score.round).order('min_score desc')
      end
      grade
    end

  end
end
