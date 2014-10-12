require 'spec_helper'

module Ransack
  describe Predicate do

    before do
      @s = Search.new(Person)
    end

    shared_examples 'wildcard escaping' do |method, regexp|
      it 'automatically converts integers to strings' do
        subject.parent_id_cont = 1
        expect { subject.result }.to_not raise_error
      end

      it "escapes '%', '.' and '\\\\' in value" do
        subject.send(:"#{method}=", '%._\\')
        expect(subject.result.to_sql).to match(regexp)
      end
    end

    describe 'eq' do
      it 'generates an equality condition for boolean true' do
        @s.awesome_eq = true
        field = "#{quote_table_name("people")}.#{quote_column_name("awesome")}"
        expect(@s.result.to_sql).to match /#{field} = #{
          ActiveRecord::Base.connection.quoted_true}/
      end

      it 'generates an equality condition for boolean false' do
        @s.awesome_eq = false
        field = "#{quote_table_name("people")}.#{quote_column_name("awesome")}"
        expect(@s.result.to_sql).to match /#{field} = #{
          ActiveRecord::Base.connection.quoted_false}/
      end

      it 'does not generate a condition for nil' do
        @s.awesome_eq = nil
        expect(@s.result.to_sql).not_to match /WHERE/
      end
    end

    describe 'lteq' do
      it 'generates a <= condition with an integer column' do
        val = 1000
        @s.salary_lteq = val
        field = "#{quote_table_name("people")}.#{quote_column_name("salary")}"
        expect(@s.result.to_sql).to match /#{field} <= #{val}/
      end

      it 'generates a <= condition with a string column' do
        val = 'jane@doe.com'
        @s.email_lteq = val
        field = "#{quote_table_name("people")}.#{quote_column_name("email")}"
        expect(@s.result.to_sql).to match /#{field} <= '#{val}'/
      end

      it 'does not generate a condition for nil' do
        @s.salary_lteq = nil
        expect(@s.result.to_sql).not_to match /WHERE/
      end
    end

    describe 'lt' do
      it 'generates a < condition with an integer column' do
        val = 2000
        @s.salary_lt = val
        field = "#{quote_table_name("people")}.#{quote_column_name("salary")}"
        expect(@s.result.to_sql).to match /#{field} < #{val}/
      end

      it 'generates a < condition with a string column' do
        val = 'jane@doe.com'
        @s.email_lt = val
        field = "#{quote_table_name("people")}.#{quote_column_name("email")}"
        expect(@s.result.to_sql).to match /#{field} < '#{val}'/
      end

      it 'does not generate a condition for nil' do
        @s.salary_lt = nil
        expect(@s.result.to_sql).not_to match /WHERE/
      end
    end

    describe 'gteq' do
      it 'generates a >= condition with an integer column' do
        val = 300
        @s.salary_gteq = val
        field = "#{quote_table_name("people")}.#{quote_column_name("salary")}"
        expect(@s.result.to_sql).to match /#{field} >= #{val}/
      end

      it 'generates a >= condition with a string column' do
        val = 'jane@doe.com'
        @s.email_gteq = val
        field = "#{quote_table_name("people")}.#{quote_column_name("email")}"
        expect(@s.result.to_sql).to match /#{field} >= '#{val}'/
      end

      it 'does not generate a condition for nil' do
        @s.salary_gteq = nil
        expect(@s.result.to_sql).not_to match /WHERE/
      end
    end

    describe 'gt' do
      it 'generates a > condition with an integer column' do
        val = 400
        @s.salary_gt = val
        field = "#{quote_table_name("people")}.#{quote_column_name("salary")}"
        expect(@s.result.to_sql).to match /#{field} > #{val}/
      end

      it 'generates a > condition with a string column' do
        val = 'jane@doe.com'
        @s.email_gt = val
        field = "#{quote_table_name("people")}.#{quote_column_name("email")}"
        expect(@s.result.to_sql).to match /#{field} > '#{val}'/
      end

      it 'does not generate a condition for nil' do
        @s.salary_gt = nil
        expect(@s.result.to_sql).not_to match /WHERE/
      end
    end

    describe 'cont' do
      it_has_behavior 'wildcard escaping', :name_cont,
        (if ActiveRecord::Base.connection.adapter_name == "PostgreSQL"
          /"people"."name" ILIKE '%\\%\\._\\\\%'/
        elsif ActiveRecord::Base.connection.adapter_name == "Mysql2"
          /`people`.`name` LIKE '%\\\\%\\\\._\\\\\\\\%'/
        else
         /"people"."name" LIKE '%%._\\%'/
        end) do
        subject { @s }
      end

      it 'generates a LIKE query with value surrounded by %' do
        @s.name_cont = 'ric'
        field = "#{quote_table_name("people")}.#{quote_column_name("name")}"
        expect(@s.result.to_sql).to match /#{field} I?LIKE '%ric%'/
      end
    end

    describe 'not_cont' do
      it_has_behavior 'wildcard escaping', :name_not_cont,
        (if ActiveRecord::Base.connection.adapter_name == "PostgreSQL"
          /"people"."name" NOT ILIKE '%\\%\\._\\\\%'/
        elsif ActiveRecord::Base.connection.adapter_name == "Mysql2"
          /`people`.`name` NOT LIKE '%\\\\%\\\\._\\\\\\\\%'/
        else
         /"people"."name" NOT LIKE '%%._\\%'/
        end) do
        subject { @s }
      end

      it 'generates a NOT LIKE query with value surrounded by %' do
        @s.name_not_cont = 'ric'
        field = "#{quote_table_name("people")}.#{quote_column_name("name")}"
        expect(@s.result.to_sql).to match /#{field} NOT I?LIKE '%ric%'/
      end
    end

    describe 'true' do
      it 'generates an equality condition for boolean true' do
        @s.awesome_true = true
        field = "#{quote_table_name("people")}.#{quote_column_name("awesome")}"
        expect(@s.result.to_sql).to match /#{field} = #{
          ActiveRecord::Base.connection.quoted_true}/
      end

      it 'generates an inequality condition for boolean true' do
        @s.awesome_true = false
        field = "#{quote_table_name("people")}.#{quote_column_name("awesome")}"
        expect(@s.result.to_sql).to match /#{field} != #{
          ActiveRecord::Base.connection.quoted_true}/
      end
    end

    describe 'not_true' do
      it 'generates an inequality condition for boolean true' do
        @s.awesome_not_true = true
        field = "#{quote_table_name("people")}.#{quote_column_name("awesome")}"
        expect(@s.result.to_sql).to match /#{field} != #{
          ActiveRecord::Base.connection.quoted_true}/
      end

      it 'generates an equality condition for boolean true' do
        @s.awesome_not_true = false
        field = "#{quote_table_name("people")}.#{quote_column_name("awesome")}"
        expect(@s.result.to_sql).to match /#{field} = #{
          ActiveRecord::Base.connection.quoted_true}/
      end
    end

    describe 'false' do
      it 'generates an equality condition for boolean false' do
        @s.awesome_false = true
        field = "#{quote_table_name("people")}.#{quote_column_name("awesome")}"
        expect(@s.result.to_sql).to match /#{field} = #{
          ActiveRecord::Base.connection.quoted_false}/
      end

      it 'generates an inequality condition for boolean false' do
        @s.awesome_false = false
        field = "#{quote_table_name("people")}.#{quote_column_name("awesome")}"
        expect(@s.result.to_sql).to match /#{field} != #{
          ActiveRecord::Base.connection.quoted_false}/
      end
    end

    describe 'not_false' do
      it 'generates an inequality condition for boolean false' do
        @s.awesome_not_false = true
        field = "#{quote_table_name("people")}.#{quote_column_name("awesome")}"
        expect(@s.result.to_sql).to match /#{field} != #{
          ActiveRecord::Base.connection.quoted_false}/
      end

      it 'generates an equality condition for boolean false' do
        @s.awesome_not_false = false
        field = "#{quote_table_name("people")}.#{quote_column_name("awesome")}"
        expect(@s.result.to_sql).to match /#{field} = #{
          ActiveRecord::Base.connection.quoted_false}/
      end
    end

    describe 'null' do
      it 'generates a value IS NULL query' do
        @s.name_null = true
        field = "#{quote_table_name("people")}.#{quote_column_name("name")}"
        expect(@s.result.to_sql).to match /#{field} IS NULL/
      end

      it 'generates a value IS NOT NULL query when assigned false' do
        @s.name_null = false
        field = "#{quote_table_name("people")}.#{quote_column_name("name")}"
        expect(@s.result.to_sql).to match /#{field} IS NOT NULL/
      end
    end

    describe 'not_null' do
      it 'generates a value IS NOT NULL query' do
        @s.name_not_null = true
        field = "#{quote_table_name("people")}.#{quote_column_name("name")}"
        expect(@s.result.to_sql).to match /#{field} IS NOT NULL/
      end

      it 'generates a value IS NULL query when assigned false' do
        @s.name_not_null = false
        field = "#{quote_table_name("people")}.#{quote_column_name("name")}"
        expect(@s.result.to_sql).to match /#{field} IS NULL/
      end
    end

    describe 'present' do
      it %q[generates a value IS NOT NULL AND value != '' query] do
        @s.name_present = true
        field = "#{quote_table_name("people")}.#{quote_column_name("name")}"
        expect(@s.result.to_sql).to match /#{field} IS NOT NULL AND #{field} != ''/
      end

      it %q[generates a value IS NULL OR value = '' query when assigned false] do
        @s.name_present = false
        field = "#{quote_table_name("people")}.#{quote_column_name("name")}"
        expect(@s.result.to_sql).to match /#{field} IS NULL OR #{field} = ''/
      end
    end

    describe 'blank' do
      it %q[generates a value IS NULL OR value = '' query] do
        @s.name_blank = true
        field = "#{quote_table_name("people")}.#{quote_column_name("name")}"
        expect(@s.result.to_sql).to match /#{field} IS NULL OR #{field} = ''/
      end

      it %q[generates a value IS NOT NULL AND value != '' query when assigned false] do
        @s.name_blank = false
        field = "#{quote_table_name("people")}.#{quote_column_name("name")}"
        expect(@s.result.to_sql).to match /#{field} IS NOT NULL AND #{field} != ''/
      end
    end
  end
end
