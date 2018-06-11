# Day 3

### 새로운 폴더에 sinatra 프로젝트 넣기

- `app.rb` 파일 생성 후 `views` 폴더 생성
- `sinatra` 와 `sinatra-reloader` 잼을 설치

*test_app/app.rb*

```
require 'sinatra'
require 'sinatra/reloader'

get '/' do
	erb :app
end
```

## 오늘 수업 내용

- Form 이용해보기
- GET방식과 POST방식
- Parameter(wildcard)
- 구글/네이버 검색창 만들기
- fake op.gg 만들기

### Form 이용하기

*views/numbers.erb*

```
<form action="/calculate" method="GET">
    첫번째 숫자: <input type="text" name="n1">
    두번째 숫자: <input type="text" name="n2">
    <input type="submit" value="계산하기">
</form>
```

*views/calculate.erb*

```
<ul>
    <li>합: <%= @sum %></li>
    <li>차: <%= @min %></li>
    <li>곱: <%= @mul %></li>
    <li>나누기: <%= @div %></li>
</ul>
```

*app.rb*

```
...
get '/numbers' do
    erb :numbers
end 
get '/calculate' do
    get '/calculate' do
    num1 = params[:n1].to_i
    num2 = params[:n2].to_i
    @sum = num1 + num2
    @min = num1 - num2
    @mul = num1 * num2
    @div = num1 / num2
    erb :calculate
end
end
...
```

- 다른 페이지에 데이터를 전송할 때에는 `form` 을 이용하여 전송하게 된다.
- 다른 페이지로 이동하는 방법에는 `a` 태그와 `form` 태그를 이용한다.
- `form` 태그는 데이터와 함께 전송할 때 사용한다.

### GET과 POST의 차이

- `form` 태그를 이용할 때 `method` 속성 값에 따라 GET과 POST를 설정할 수 있다.
- GET 방식은 url에 데이터를 포함하는 반면에 POST 방식은 request body에 데이터를 포함하여 전송한다.
- GET 방식은 url 길이에 의해 data의 길이를 제한받을 수 있는 POST 방식은 길이의 제한이 없다.

*views/form.erb*

```
<form action="/login" method="POST">
    아이디: <input type="text" name="id">
    비밀번호: <input type="password" name="password">
    <input type="submit" value="로그인">
</form>
```

*views/error.erb*

```
<h1>너가 입력한 정보에 문제가 있는데요?</h1>
```

*views/complete.erb*

```
<h1>로그인이 완료되었습니다.</h1>
```

*app.rb*

```
...

id = "multi"
pw = "campus"

post '/login' do
    if id.eql?(params[:id])
        # 비밀번호를 체크하는 로직
        if pw.eql?(params[:password])
            redirect '/complete'
        else
            @msg = "비밀번호가 틀립니다."
            redirect '/error'
        end
    else
        # ID가 존재하지 않습니다
        @msg = "ID가 존재하지 않습니다."
        redirect '/error'
    end
end
# 계정이 존재하지 않거나, 비밀번호가 틀린경우
get '/error' do
    # 다른 방식으로 에러메시지를 보여줘야함
    erb :error
end
# 로그인 완료된 곳
get '/complete' do
    erb :complete
end
...
```

- 기본적으로 POST 요청에 대한 로직은 직접 뷰를 렌더링하는 것이 아니라 다른 페이지로 redirect 시킨다.
- 새로고침등을 통한 접속불가 등의 현상을 막기위한 방편이다.
- 이후 게시판 글을 만드는 요청에 대한 로직을 구성할 때에도 동일한 방식으로 구성한다.

### 가짜 구글/네이버 검색창 만들기

- `redirect` 나 `form`의 action 속성을 이용하면 외부의 사이트에 접근하는 것도 가능하다.

*views/search.erb*

```
<p>----form action을 이용한 방법----</p>
<form action="https://search.naver.com/search.naver">
    <input type="text" name="query" placeholder="네이버 검색창">
    <input type="submit">
</form>

<form action="https://www.google.com/search">
    <input type="text" name="q" placeholder="구글 검색창">
    <input type="submit">
</form>

<p>----form method POST를 이용한 방법----</p>
<form method="POST">
    <input type="hidden" name="engine" value="naver">
    <input type="text" name="query" placeholder="네이버 검색">
    <input type="submit" value="검색">
</form>

<form method="POST">
    <input type="hidden" name="engine" value="google">
    <input type="text" name="q" placeholder="구글 검색">
    <input type="submit" value="검색">
</form>
```

*app.rb*

```
...
get '/search' do
    erb :search
end

post '/search' do
    case params[:engine]
    when "naver"
        url = URI.encode("https://search.naver.com/search.naver?query=#{params[:query]}")
        redirect url
    when "google"
        url = URI.encode("https://www.google.com/search?q=#{params[:q]}")
        redirect url
    end
end
...
```

- 같은 html 파일 안에 여러개의 `form` 태그를 넣는 것이 가능하며 각각의 `form` 태그가 설정한 action 속성에 따라 데이터를 전달하는 페이지가 달라진다.
- 한글 검색어를 처리하기 위해서 `require 'uri'` 와 `URI.encode` 를 추가한다.

### Fake op.gg 만들기

- 가짜 검색창에서 이용한 것에 이어 *op.gg*에서 검색결과를 보는 것과 자체 페이지에서 크롤링을 통해 승과 패만 가지고 오는 방식으로 나눴다.

*views/op_gg.erb*

```
<form>
    <select name="search_method" required="true">
        <option></option>
        <option value="self">승패만보기</option>
        <option value="opgg">OP.GG에서 보기</option>
    </select>
    <input type="text" placeholder="소환사 이름" name="userName" required="true">
    <input type="submit" value="검색">
</form>

<% if params[:userName] %>
<ul>
    <li><%= params[:userName] %>님의 전적입니다.</li>
    <li><%= @win %> 승</li>
    <li><%= @lose %> 패</li>
</ul>
<% end %>
```

*app.rb*

```
...
get '/op_gg' do
    if params[:userName]
        case params[:search_method]
        # op.gg에서 승/패 수만 크롤링하여 보여줌
        when "self"
            # RestClient를 통해 op.gg에서 검색결과 페이지를 크롤링
            url = RestClient.get(URI.encode("http://www.op.gg/summoner/userName=#{params[:userName]}"))
            # 검색결과 페이지 중에서 win과 lose 부분을 찾음
            result = Nokogiri::HTML.parse(url)
            # nokogiri를 이용하여 원하는 부분을 골라냄
            win = result.css('span.win').first
            lose = result.css('span.lose').first
            # 검색 결과를 페이지에서 보여주기 위한 변수 선언
            @win = win.text
            @lose = lose.text
            
        # 검색결과를 op.gg에서 보여줌
        when "opgg"
            url = URI.encode("http://www.op.gg/summoner/userName=#{params[:userName]}")
            redirect url
        end
    end
    erb :op_gg
end
...
```

- `erb` 파일에서는 루비에서 사용한 변수나 문법을 사용하는 것이 가능하다.

> 주의해야 할 것은 '눈에 보이는것'과 '눈에 보이지 않는 것이다.' 개발자는 볼 수 있지만 사용자는 보이면 안되는 것들이 있는데 대표적으로 조건문, 반복문 등이 있다. 로직에 해당하는 것들을 보여지지 않게 하기 위해서 `erb` 파일에서 사용하던 `<%= %>` 태그를 `<% %>` 의 형태로 작성한다.