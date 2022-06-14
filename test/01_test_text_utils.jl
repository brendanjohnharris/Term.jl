import Term:
    remove_markup,
    has_markup,
    remove_ansi,
    has_ansi,
    get_last_ANSI_code,
    cleantext,
    textlen,
    escape_brackets,
    unescape_brackets,
    replace_text,
    replace_ansi,
    nospaces,
    remove_brackets,
    unspace_commas,
    chars,
    join_lines,
    split_lines,
    textwidth,
    fillin,
    truncate,
    reshape_text
import Term.Style: apply_style
import Term.Measures: width as get_width

@testset "TU_markup" begin
    strings = [
        (
            "this is {red} some {blue} text {/blue} that I like{/red}",
            "this is  some  text  that I like",
        ),
        (
            "{bold underline} this is {red on_green} text {/red on_green} I like {/bold underline}",
            " this is  text  I like ",
        ),
    ]

    for (s1, s2) in strings
        @test has_markup(s1)
        @test remove_markup(s1) == s2
        @test cleantext(s1) == s2
        @test textlen(s1) == textwidth(s2)
    end

    @test remove_markup("text with {{double}} squares") == "text with {{double}} squares"
    @test !has_markup("text with {{double}} squares")
end

@testset "TU_ansi" begin
    apply_style("test{(.2, .5, .6)}coloooor{/(.2, .5, .6)}")
    strings = [
        (
            "this is \e[31m some \e[34m text \e[39m\e[31m that I like\e[39m",
            "this is  some  text  that I like",
            "\e[39m",
        ),
        (
            "\e[1m\e[4m this is \e[31m\e[42m text \e[39m\e[49m\e[4m I like \e[22m\e[24m",
            " this is  text  I like ",
            "\e[24m",
        ),
        (
            "test\e[38;2;51;128;153mcoloooor\e[39m and white",
            "testcoloooor and white",
            "\e[39m",
        ),
    ]

    for (s1, s2, ltag) in strings
        @test has_ansi(s1)
        @test remove_ansi(s1) == s2
        @test get_last_ANSI_code(s1) == ltag
    end
end

@testset "TU_replace_text" begin
    text = "abcdefghilmnopqrstuvz"

    @test replace_text(text, 0, 5, "aaa") == "aaafghilmnopqrstuvz"
    @test replace_text(text, 0, 5, ',') == ",,,,,fghilmnopqrstuvz"

    @test replace_text(text, 18, 21, "aaa") == "abcdefghilmnopqrstaaa"
    @test replace_text(text, 18, 21, ',') == "abcdefghilmnopqrst,,,"

    @test replace_text(text, 10, 15, "aaa") == "abcdefghilaaarstuvz"
    @test replace_text(text, 10, 15, ',') == "abcdefghil,,,,,rstuvz"

    @test nospaces("a (1, 2, 3) 4") == "a(1,2,3)4"
    @test remove_brackets("aaa (asdsd) BB") == "aaa asdsd BB"

    @test unspace_commas("a, 2, 3") == "a,2,3"
end

@testset "TU_replace_ansi" begin
    text = apply_style(
        "Lorem {red}ipsum dolor sit {underline}amet, consectetur{/underline} adipiscing elit, {/red}{blue}sed do eiusmod tempor incididunt{/blue} ut labore et dolore magna aliqua."
    )

    @test replace_ansi(text) == "Lorem ¦¦¦¦¦ipsum dolor sit ¦¦¦¦amet, consectetur¦¦¦¦¦¦¦¦¦¦ adipiscing elit, ¦¦¦¦¦¦¦¦¦¦sed do eiusmod tempor incididunt¦¦¦¦¦ ut labore et dolore magna aliqua."
end

@testset "TU_misc" begin
    @test chars("abcd") == ['a', 'b', 'c', 'd']

    strings = [
        "aaa\nadasda\nasdasda",
        """
        asdasd
adsada
asddsa""",
    ]
    for str in strings
        @test join_lines(split_lines(str)) == str
    end
end

@testset "TU_reshape" begin
    str = """
Lorem ipsum {bold}dolor sit{/bold} amet, consectetur adipiscing elit,
ed do e{red}iusmod tempor incididunt{/red} ut {bold}labore et {underline}dolore{/underline} magna aliqua.{/bold} Ut enim ad minim
veniam, quis{green} nostrud exercitation {on_black}ullamco laboris nisi ut aliquip ex {/on_black}
ea commodo consequat.{blue} Duis aute irure dolor in{/blue} reprehenderit 
in voluptate velit{/green} esse {italic}cillum dolore{/italic}{red} eu{/red}{italic green} fugiat {/italic green}nulla 
pariatur. Excepteur{red} sint{/red}{blue} occaecat cupidatat {/blue}non proident, 
sunt in culpa qui {italic}officia{/italic} deserunt mollit anim 
id est laborum."""

    str_reshaped = "Lorem ipsum \e[1mdolor sit\e[22m amet, \nconsectetur adipiscing elit,\ned do e\e[31miusmod tempor incididunt\e[39m \nut \e[1mlabore et \e[4mdolore\e[24m\e[1m magna \naliqua.\e[22m\e[39m Ut enim ad minim\nveniam, quis\e[32m nostrud \n\e[32mexercitation \e[40mullamco laboris \n\e[32mnisi ut aliquip ex \e[49m\e[32m\e[39m\e[39m\e[32m\e[39m\e[40m\nea commodo consequat.\e[34m Duis aute \nirure dolor in\e[39m reprehenderit \nin voluptate velit\e[39m\e[3m esse \e[3mcillum \ndolore\e[23m\e[31m eu\e[39m\e[23m\e[3m\e[32m fugiat \e[23m{/green}nulla \npariatur. Excepteur\e[31m sint\e[39m\e[34m \noccaecat cupidatat \e[39mnon proident, \nsunt in culpa qui \e[3mofficia\e[23m \ndeserunt mollit anim \nid est laborum."

    logo_str = """Term.jl is a {#9558B2}Julia{/#9558B2} package for creating styled terminal outputs.

    Term provides a simple {italic green4 bold}markup language{/italic green4 bold} to add {bold bright_blue}color{/bold bright_blue} and {bold underline}styles{/bold underline} to your text.
    More complicated text layout can be created using {red}"Renderable"{/red} objects such 
    as {red}"Panel"{/red} and {red}"TextBox"{/red}.
    These can also be nested and stacked to create {italic pink3}fancy{/italic pink3} and {underline}informative{/underline} terminal ouputs for your Julia code"""

    logo_str_reshaped = "Term.jl is a \e[38;2;149;88;178mJulia\e[39m package for \ncreating styled terminal outputs.\n\nTerm provides a simple \e[3m\e[38;5;28m\e[1mmarkup \nlanguage\e[23m\e[39m\e[3m\e[22m\e[38;5;28m to add \e[1m\e[38;5;12mcolor\e[22m\e[38;5;28m\e[39m\e[1m and \e[1m\e[4mstyles\e[22m\e[1m\e[24m\e[1m \nto your text.\nMore complicated text layout can \nbe created using \e[31m\"Renderable\"\e[39m \nobjects such \nas {red}\"Panel\"{/red} and {red}\"TextBox\"{/red}.\nThese can also be nested and \nstacked to create \e[3m\e[38;5;175mfancy\e[23m\e[39m\e[3m and \n\e[4minformative\e[24m\e[3m terminal ouputs for \nyour Julia code"

    strings = [
        (
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
            "Lorem ipsum dolor sit amet, \nconsectetur adipiscing elit, sed \ndo eiusmod tempor incididunt ut \nlabore et dolore magna aliqua.",
        ),
        (
            "Lorem {red}ipsum dolor sit {underline}amet, consectetur{/underline} adipiscing elit, {/red}{blue}sed do eiusmod tempor incididunt{/blue} ut labore et dolore magna aliqua.",
            "Lorem \e[31mipsum dolor sit \e[4mamet, \nconsectetur\e[24m\e[31m adipiscing elit, \e[39m\e[34msed \ndo eiusmod tempor incididunt\e[39m ut \nlabore et dolore magna aliqua.",
        ),
        (
            "Lorem{red}ipsumdolorsit{underline}amet, consectetur{/underline} adipiscing elit, {/red}seddoeiusmo{blue}dtemporincididunt{/blue}ut labore et dolore magna aliqua.",
            "Lorem\e[31mipsumdolorsit\e[4mamet, \nconsectetur\e[24m\e[31m adipiscing elit, \n\e[39mseddoeiusmo\e[34mdtemporincididunt\e[39mut \nlabore et dolore magna aliqua.",
        ),
        (
            "ต้าอ่วยวาทกรรมอาว์เซี้ยว กระดี๊กระด๊า ช็อปซาดิสต์โมจิดีพาร์ตเมนต์ อินดอร์วิว สี่แยกมาร์กจ๊อกกี้ โซนี่บัตเตอร์ฮันนีมูน ยาวีแพลนหงวนสคริปต์ แจ็กพ็อตต่อรองโทรโข่งยากูซ่ารุมบ้า บอมบ์เบอร์รีวีเจดีพาร์ทเมนท์ บอยคอตต์เฟอร์รี่บึมมาราธอน ",
            "ต้าอ่วยวาทกรรมอาว์เซี้ยว กระดี๊กระด๊า \nช็อปซาดิสต์โมจิดีพาร์ตเมนต์ อินดอร์วิว \nสี่แยกมาร์กจ๊อกกี้ โซนี่บัตเตอร์ฮันนีมูน \nยาวีแพลนหงวนสคริปต์ \nแจ็กพ็อตต่อรองโทรโข่งยากูซ่ารุมบ้า \nบอมบ์เบอร์รีวีเจดีพาร์ทเมนท์ \nบอยคอตต์เฟอร์รี่บึมมาราธอน ",
        ),
        (
            "ต้าอ่วยวาท{red}กรรมอาว์เซี้ยว กระดี๊กระด๊า {/red}ช็อปซาดิสต์โมจิดีพาร์ตเม{blue underline}นต์ อินดอร์วิว สี่แยกมาร์กจ๊อกกี้ โซนี่บัตเต{/blue underline}อร์ฮันนีมูน ยาวีแพลนหงวนสคริปต์ แจ็กพ็อตต่อรองโทรโข่งยากูซ่ารุมบ้า บอมบ์เบอร์รีวีเจดีพาร์ทเมนท์ บอยคอตต์เฟอร์รี่บึมมาราธอน ",
            "ต้าอ่วยวาท\e[31mกรรมอาว์เซี้ยว กระดี๊กระด๊า \n\e[39mช็อปซาดิสต์โมจิดีพาร์ตเม\e[34m\e[4mต์ อินดอร์วิว \nสี่แยกมาร์กจ๊อกกี้ โซนี่บัตเต\e[39m\e[24m\e[34m}อร์ฮันนีมูน \nยาวีแพลนหงวนสคริปต์ \nแจ็กพ็อตต่อรองโทรโข่งยากูซ่ารุมบ้า \nบอมบ์เบอร์รีวีเจดีพาร์ทเมนท์ \nบอยคอตต์เฟอร์รี่บึมมาราธอน ",
        ),
        (
            "국가유공자·상이군경 및 전몰군경의 유가족은 법률이 정하는 바에 의하여",
            "국가유공자·상이군경 및 \n전몰군경의 유가족은 법률이 \n정하는 바에 의하여",
        ),
        (
            "국{red}가유공자·상이군{bold}경 및 전{/bold}몰군경의 유{/red}가족은 법률이 정하는 바에 의하여",
            "국\e[31m가유공자·상이군\e[1m경 및 \n전\e[22m\e[31m몰군경의 유\e[39m가족은 법률이 \n정하는 바에 의하여",
        ),
        (
            "朗眠裕安無際集正聞進士健音社野件草売規作独特認権価官家複入豚末告設悟自職遠氷育教載最週場仕踪持白炎組特曲強真雅立覧自価宰身訴側善論住理案者券真犯著避銀楽験館稿告",
            "朗眠裕安無際集正聞進士健音社野件\n草売規作独特認権価官家複入豚末告\n設悟自職遠氷育教載最週場仕踪持白\n炎組特曲強真雅立覧自価宰身訴側善\n論住理案者券真犯著避銀楽験館稿告",
        ),
        (
            "┌────────────────┬────────────────┬────────────────┬────────────────┬──────────────",
            "┌────────────────┬───────────────\n─┬────────────────┬──────────────\n──┬──────────────",
        ),
        (
            "┌────────────abcde────┬──────────── ────┬────────abcde fghi────────┬────────────────┬──────────────",
            "┌────────────abcde────┬──────────\n── ────┬────────abcde \nfghi────────┬────────────────┬───\n───────────",
        ),
        (
            "┌─────────{red}───ab{/red}cde────┬──────{green}────── ────┬────────abcde fghi{/green}────────┬────────────────┬──────────────",
            "┌─────────\e[31m───ab\e[39mcde────\n┬──────\e[32m────── \n────┬────────abcde \nfghi\e[39m────────┬────────────\n────┬──────────────",
        ),
        (
            "┌──────────{red}────{/red}──┬{blue bold}────────────────┬──{/blue bold}──────────────┬────────────────┬──────────────end",
            "┌──────────\e[31m────\e[39m──┬\e[1m───────────────┬──{/blue}\n\e[22m\e[39m}──────────────┬──────────\n──────┬──────────────end\e[39m",
        ),
        (
            "."^100,
            ".................................\n.................................\n.................................\n.",
        ),
        (
            ".{red}|||{/red}...."^10,
            ".\e[31m|||\e[39m.....\e[31m|||{/red\n}.....\e[31m|||\e[39m.....\e[31m|||\n\e[39m\e[31m.....\e[31m|||\e[39m.....|||\e[39m\e[31m.....\e[31m|||\e[39m\e[31m...\n..\e[31m|||\e[39m\e[31m.....\e[31m|||\e[39m.....\e[31m|||\e[39m\e[31m....\e[39m",
        ),
        (
            ".|||...."^10,
            ".|||.....|||.....|||.....|||.....\n|||.....|||.....|||.....|||.....|\n||.....|||....",
        ),
        (str, str_reshaped),
        (logo_str, logo_str_reshaped),
    ]

    width = 33
    debug = false
    for (i, (input, expected)) in enumerate(strings)
        reshaped = reshape_text(input, width)
        reshaped_no_ansi = remove_ansi(reshaped)
        lens = length.(split(reshaped_no_ansi, '\n'))
        if debug && reshaped != expected
            println("== reshaped == ")
            println(reshaped)
            println(repr(reshaped))
            println("\n== reshaped no ansi == ")
            println(reshaped_no_ansi)
            println("\n== expected == ")
            println(expected)
        end
        # FIXME: should work when `length(input) != ncodeunits(input)` using non unit byte characters: see docs.julialang.org/en/v1/manual/strings/#Unicode-and-UTF-8
        if length(input) == ncodeunits(input) && !occursin('\n', input)
            (debug && any(lens .> width)) && println(lens)
            @test all(lens .≤ width)
        end
        @test reshaped == expected
    end

    for width in (40, 60, 99)
        rh = reshape_text(str, width)
        @test all(textlen.(split(rh, '\n')) .≤ width)
    end

    for i in 5:10
        width = 2^i
        for offset in (-(width ÷ 2)):(width ÷ 2)
            txt = '.'^(2width + offset)
            rt = reshape_text(txt, width)
            len = length.(split(rt, '\n'))
            # @show length(txt) width rt len
            @test all(len[1:(end - 1)] .== width)
            @test len[end] == (offset > 0 ? offset : width + offset)
        end
    end
end
