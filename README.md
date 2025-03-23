# エリオ :: Erio

A very chubby, tiny and lightweight Web Framework(base on Rack)

凄く小さいなウェブ・フラムワーク。

<style>
  [cols-2] { column-count: 2 }
  [cols-3] { column-count: 3 }
  [cols-4] { column-count: 4 }
</style>

## インストール :: Installation

```bash
gem install erio
```

## 使い方法 :: Usage

```ruby
require 'erio'

class Touwa < Erio
  enter do
    status 200
    header content_type: 'html'
    if accept? 'image' and not accept? %w[text application]
      send_file '/public'+path
    elsif path? '/'
      '<h1>Hello, Erio!</h1>'
    elsif query? id: 1
      content_type 'json'
      { id: 1, name: 'Touwa Erio', country: 'Japan' }.to_json
    else
      status 404
      "<h1><b>404</b> - not found page</h1><hr><h2>\"#{path}\"</h2>"
    end
  end
end

Touwa.run!

```

### 綺麗になた :: More Usefule

```ruby

# エリオは何の為？
Erio.enter do |o|
  # 来訪ノ時に記録。
  t0 = Time.now
  # 状態番号 200
  o.status 200

  # 見目タイプに判断と反応する。
  if o.accept? %w[image video audio] and not o.accept? %w[text application]
    # 内容タイプのヘーダに設定。
    o.header content_type: o.path.split('.')[-1]
    begin
    # ファイルに発送。
      o.body File.binread('public'+path)
    rescue => err
    # ファイルに有りませんならば、異常ニ報告する。
      puts err
      o.status 404
      o.body 'miss'
    end
    # ＨＰに展覧。
  elsif o.path? '/'
    o.header content_type: 'text'
    o.body 'hi'
  else
    # いないノ場合...
    o.status 404
    o.body 'miss'
  end
  # 毎回ノ来訪をログ。
  puts "#{o.ip} [#{t0}] #{o.verb} #{o.path} #{o.query} #{o.accept.scan(/\w+(?=\/)/).uniq.join(',')} #{"%.04f" % (Time.now-t0).to_f}"
end

# エリオ開始。
Erio.run!
```

### 迷う宮ノ様な回路ニ作ろう :: Nested Page Sugar


複雑ノ回路もサポートします。
同じのコードを繰り返し書き込みの面倒も遠慮なく。

<figure cols-2>

タイプ·Ｍ

```yaml
- user
  - 123
    - album
      - 23
```

タイプ·Ｓ

```yaml
- /user
- /user/123
- /user/123/album
- /user/123/album/23

```

</figure>

そして、処理に引きされば...

<figure cols-2>

タイプ·Ｍ

```yaml
- user
  # 処理 user
  - ''
    # 処理·根
  - 123
    # 処理 123
    - ''
      # 処理·根
    - album
      # 処理 album
      - ''
        # 処理·根
      - 23
        # 処理 23
```

タイプ·Ｓ

```yaml
- /user
  # 処理 user
  # 処理·根
- /user/123
  # 処理 user
  # 処理 123
  # 処理·根
- /user/123/album
  # 処理 user
  # 処理 123
  # 処理 album
  # 処理·根
- /user/123/album/23
  # 処理 user
  # 処理 123
  # 処理 album
  # 処理 23

```

</figure>

#### 実のコードご覧。


<figure cols-2>

回路ニ使える

```ruby
on 'user'
  content_type 'html'
  is do
    echoln 'userlist...'
  end

  on Integer do |uid|
    is do
      echoln "user: #{uid}"
    end

    on 'album' do
      echoln "user #{uid}'s album"
      is do
        echoln "pics..."
        for pic in Dir["asset/user/#{uid}/*.png"]
          echoln "<img src=\"#{pic}\">"
        end
      end

      is Integer do |pn|
        echoln "pic #{pn}"
        echoln "<img src=\"asset/#{uid}/#{pn}.png\">"
      end
    end
  end
end
```

回路に使えないならば...線性パス

```ruby
on '/user' do
  content_type 'html'
  echoln 'userlist...'
end

on '/user/:uid' do |uid|
  content_type 'html'
  echoln "user: #{uid}"
end

on '/user/:uid/album' do |uid|
  content_type 'html'
  echoln "user #{uid}'s album"
  echoln "pics..."
  for pic in Dir["asset/user/#{uid}/*.png"].map
    echoln "<img src=\"#{pic}\">"
  end
end

on '/user/:uid/album/:pn' do |uid, pn|
  content_type 'html'
  echoln "user #{uid}'s album"
  echoln "pic #{pn}"
  echoln "<img src=\"asset/#{uid}/#{pn}.png\">"
end
```

</figure>

試験コードご覧ください

```ruby

Erio.enter do
  # 唯ルト、残されパスは無いノ場合。
  is do
    echo 'home'
  end
  # 前に合わせてならば... そして引数を取って。
  on 'user', Integer do |_, uid|
    # 唯此れニ合わせて
    is do
      echo "space of user: #{uid}."
    end
    # リクエストのパラメータも取って。
    is 'album', param(pn: Integer) do |_, pn|
      content_type 'html'
      echo "picture of user: #{uid} <img src=\"#{pn}.png\">"
    end
  end

  # 後ノ条件も合わせてしたい。
  also

  # ご報告ニ送りします
  on param(:warn) do
    puts "warn #{ip} - #{verb} #{path}"
  end
end

```

## 作ル人 :: Creator

__SAISUI__ :: 彩穂

tip from `rack`, `sinatra`, `rum`

## コード協力 :: Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/saisui/erio-rb. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/saisui/erio-rb/blob/master/CODE_OF_CONDUCT.md).

## ライセンス :: License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
