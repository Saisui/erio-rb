require './lib/erio'

class Blog < Erio
  enter do
    # on 'hello' do
    #   on 'daddy' do
    #     on '' do
    #       res.write 'hi, i\'m fine.'
    #     end
    #   end
    #   on true do
    #     res.write 'hi, nobody.'
    #   end
    # end
    # on Integer do |id|
    #   res.write "int: #{id}"
    #   pp 'int'
    # end
    # on Numeric do |id|
    #   res.write "num: #{id}"
    #   pp 'num'
    # end
    # on '' do
    #   res.write 'index'
    # end
    pp path
    if path =~ /\A\/(\d+)\z/
      res.write "Hi, Your ID is #{$1}!"
      run proc { res.write 'Fuck you!' }
    end
  end
end

run Blog