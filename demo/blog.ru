require './lib/erio'
require './lib/erio/topo'
require './lib/erio/kaki'

$articles = [
  ['2025-01-01', '', 'hello, i\'m fine.', 0, []],
  ['2025-01-02', '', 'these days, i\'m sad.', 0, []],
  ['2025-01-03', '', 'current time, my best friend dead.', 0, []],
  ['2025-01-04', '', 'many people die in too poor to heal.', 0, []],
]

$watched = 0

class Blog < Erio
  enter do
    $watched += 1

    is do
      # echoln '<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.min.css">'
      echo '<title>MY BLOG</title>'
      echoln "<p><a href=\"/\">HOME</a> watched: #{$watched}</p>"
      res.content_type = 'text/html'
      echo 'welcome to HOME!'
      for ((d,tt,_,c, ccs), i) in $articles.each_with_index.to_a
        echoln "<p><a href=\"/note/#{i}\">##{i} - #{d} - #{tt}</a> view: #{c}</p>"
      end
      echoln '<hr>post a article<br>
      <input id="tt" type="text" placeholder="title"><br>
      <textarea id="tx"></textarea><br>
      <button onclick="fetch(`/note/add?title=${tt.value}&s=${tx.value}`)">POST</button>'
    end

    on 'note' do
      on Numeric do |id|
        is do
          echo "<title>#{$articles[id][1]}</title>"
          # echoln '<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.min.css">'
          echoln "<p><a href=\"/\">HOME</a> watched: #{$watched}</p>"
          $articles[id][3] += 1
          echoln "note #{id} at #{$articles[id][0]} watched #{$articles[id][3]}"
          echoln '<hr>'
          echo $articles[id][2]
          echoln %Q{<hr>reply this article<br>
          <input id="tt" type="text" placeholder="by"><br>
          <textarea id="tx"></textarea><br>
          <button onclick="fetch(`/note/#{id}/reply?by=${tt.value}&s=${tx.value}`)">SEND</button>}
          
          echoln '<hr><b>replies</b><br>'

          for re, i in $articles[id][-1].each_with_index
            echoln "##{i+1}@ <b>#{re[1]}</b> at #{re[0]} <br>"+re[2].lines.join('<br>')+'<hr>'
          end
        end
        is 'reply' do
          $articles[id][-1].push([Time.now.strftime("%Y-%m-%d %H:%M:%S"), req.params['by'], req.params['s']])
          echo 'reply success!'
        end
      end
      is 'add' do
        $articles.push([Time.now.strftime("%Y-%m-%d %H:%M:%S"), req.params['title']||'', req.params['s'], 0, []])
        echo 'post success!'
      end
    end

    if res.body.empty?
      res.write 'miss'
    end
  end
end

run Blog