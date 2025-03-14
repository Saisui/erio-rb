# エリオ :: Erio

A very chubby, tiny and lightweight Web Framework(base on Rack)

凄く小さいなウェブ・フラムワーク。

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

## 作ル人 :: Creator

__SAISUI__ :: 彩穂

tip from `rack`, `sinatra`

## コード協力 :: Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/saisui/erio-rb. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/saisui/erio-rb/blob/master/CODE_OF_CONDUCT.md).

## ライセンス :: License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
