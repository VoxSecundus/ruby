# -*- encoding: utf-8 -*-
require 'date'

class Personnummer
    # luhn will test if the given string is a valid luhn string.
    def self.luhn(str)
        v = 0
        sum = 0

        for i in 0...str.length
            v = str[i].to_i
            v *= 2 - (i % 2)
            if v > 9
                v -= 9
            end
            sum += v
        end

        return ((sum.to_f / 10).ceil * 10 - sum.to_f).to_i
    end

    # testDate will test if date is valid or not.
    def self.testDate(year, month, day)
        begin
            date = Date.new(year, month, day)
            return !(date.year != year || date.month != month || date.mday != day)
        rescue ArgumentError
            return false
        end
    end

    def self.getParts(str)
      str=str.to_s

      reg = /^(\d{2}){0,1}(\d{2})(\d{2})(\d{2})([\-|\+]{0,1})?(\d{3})(\d{0,1})$/;
      match = reg.match(str)
      century = match[1]
      year = match[2]
      month = match[3]
      day = match[4]
      sep = match[5]
      num = match[6]
      check = match[7]

      if !(sep == '-' || sep == '+')
        if (( century.nil? || !century.length) || Time.new.year - (century + year).to_i < 100)
          sep = '-'
        else
          sep = '+'
        end
      end

      if (century.nil? || !century.length)
        d = Time.new
        baseYear = 0

        if sep == '+'
          baseYear = d.year - 100
        else
          baseYear = d.year
        end
        century = "#{(baseYear - ((baseYear - year.to_i) % 100)).digits[-2..-1].reverse.join('')}"
      end
      
      return [
        century,
        year,
        month,
        day,
        sep,
        num,
        check
      ]
    end
 

    # valid will validate Swedish social security numbers.
    def self.valid(str)
        if !str.respond_to?(:to_s) || !str.respond_to?(:to_i)
            return false
        end

        reg = /^(\d{2}){0,1}(\d{2})(\d{2})(\d{2})([\-|\+]{0,1})?(\d{3})(\d{0,1})$/;
        match = str.to_s.match(reg)

        if !match
            return false
        end

        century = match[1]
        year    = match[2]
        month   = match[3]
        day     = match[4]
        sep     = match[5]
        num     = match[6]
        check   = match[7]

        if sep.to_s.empty?
            sep = '-'
        end

        valid = self.luhn(year + month + day + num) == check.to_i && !!check

        if valid && self.testDate(year.to_i, month.to_i, day.to_i)
            return valid
        end

        return valid && self.testDate(year.to_i, month.to_i, day.to_i - 60)
    end

    def self.format(input, longFormat = false)
        if !self.valid(input)
            return false
        end

        century,year,month,day,sep,num,check = self.getParts(input)

        if longFormat
          return "#{century}#{year}#{month}#{day}#{num}#{check}"
        else
          return "#{year}#{month}#{day}#{sep}#{num}#{check}"
        end
    end
end
