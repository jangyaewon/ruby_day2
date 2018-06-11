require 'sinatra'
require 'sinatra/reloader'
require 'uri'
require 'rest-client'
require 'nokogiri'

get '/numbers' do
    erb :numbers # form을 이용해 데이터를 전송시킨다.
end


get '/calculate' do # get방식
    num1 = params[:n1].to_i # 파라미터로 넘겨준 값을 가져온다.
    num2 = params[:n2].to_i
    @sum = num1 + num2 # html로 뿌릴 값을 처리할 때 @변수명 형태를 사용
    @min = num1 - num2
    @mul = num1 * num2
    @div = num1 / num2
    erb :calculate
end 

get '/form' do  #post방식은 form 페이지를 타고 들어가야 갈 수 있다. 그냥은 안되는 듯
    erb :form 
end


id = "multi"
pw = "campus"

post '/login'  do #post형식은 뷰를 직접 렌더링하는 것이 아닌 다른 페이지로 redirect한다.
    if id.eql?(params[:id])#id가 파라미터_id와 값이 같은가?
        # 비밀번호를 체크하는 로직
        if pw.eql?(params[:password])
            redirect '/complete'#같다면 성공페이지로 이동
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



# 가짜 구글/네이버 검색창 만들기
# redirect 나 form의 action 속성을 이용하면 외부의 사이트에 접근하는 것도 가능하다.

get '/search' do
    erb :search #성공적으로 간다면 post '/search'로 가게 된다.
end

post '/search' do
    # 한글 검색어를 처리하기 위해서 require 'uri' 와 URI.encode 를 추가한다.
    case params[:engine] #파라미터에 담긴 값(검색엔진 이름)에 따라
    when "naver"
        url = URI.encode("https://search.naver.com/search.naver?query=#{params[:query]}")
        redirect url
    when "google"
        url = URI.encode("https://www.google.com/search?q=#{params[:q]}")
        redirect url
    end
end



#Fake op.gg 만들기
# 1. op.gg에서 검색결과를 보는 것
# 2. 자체 페이지에서 크롤링을 통해 승과 패만 가지고 오는 방식

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

# 로직에 해당하는 것들을 보여지지 않게 하기 위해서 erb 파일에서 사용하던 <%= %> 태그를 <% %> 의 형태로 작성한다.