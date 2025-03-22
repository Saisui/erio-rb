require './lib/erio'

class App < Erio
  enter do
    is do
      res.write 'home'
    end
    on 'hello' do
      is do
        res.write 'hi'
      end
      is 'me' do
        res.write 'hello, self?'
      end
    end
    
    also
    
    on req.params.empty? do
      res.write "\nNo Parameters."
    end

    also
    
    on accept? 'text' do
      res.write "\nAccept: Text."
    end
  end
end

run App