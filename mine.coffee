class Minefield
    constructor: (@window, @columns, @rows, @num_mines, @max_mines=1) ->
        # status: 0 if started, -1 if dead, 1 if ready_to_start
        @game_status = -1

    init_board: ->
        @table = document.createElement('table')
        @table.setAttribute("class", "minetable")

        @mines = ((0 for y in [1..@rows]) for x in [1..@columns])
        @near_mines = ((0 for y in [1..@rows]) for x in [1..@columns])

        @tds = ((null for y in [1..@rows]) for x in [1..@columns])

        for y in [0..(@rows-1)]
            tr = document.createElement('tr')
            for x in [0..(@columns-1)]
                td = document.createElement('td')
                td.setAttribute("id", "x"+x+"y"+y)
                on_click_to = (x_, y_, self) ->
                    ->
                        self.on_click(x_, y_)
                        false
                td.onclick = on_click_to(x, y, this)
                on_rclick_to = (x_, y_, self) ->
                    ->
                        self.on_rclick(x_, y_)
                        false
                td.oncontextmenu = on_rclick_to(x, y, this)

                @tds[x][y] = td
                tr.appendChild(td)

            @table.appendChild(tr)

        @window.appendChild(@table)

    init_mines: ->
        num_mine_created = 0
        while num_mine_created < @num_mines
            # infinite loop with probability 0
            x = Math.floor(Math.random() * @columns)
            y = Math.floor(Math.random() * @rows)
            if @mines[x][y] < @max_mines
                @mines[x][y] = 1
                for [nx, ny] in @near_positions(x, y)
                    @near_mines[nx][ny] += 1
                num_mine_created += 1
        @game_status = 0

    near_positions: (x, y) ->
        ret = []
        for nx in [(x-1)..(x+1)]
            for ny in [(y-1)..(y+1)]
                if nx == x and ny == y
                    continue
                if nx >= @columns or nx < 0 or ny >= @rows or ny < 0
                    continue
                ret.push([nx, ny])
        ret

    on_click: (x, y) ->
        if @game_status < 0
            return
        if @game_status == 1
            @start(x, y)

        @expand(x, y)

    on_rclick: (x, y) ->
        @flag(x, y)

    start: (x, y) ->
        # TODO: first click should never die

    flag: (x, y) ->
        # TODO

    press: (x, y) ->
        if @mines[x][y] > 0
            @tds[x][y].setAttribute("class", "mine-exploded")
            @gameover(x, y)
        else if @near_mines[x][y] == 0
            @tds[x][y].setAttribute("class", "empty")
        else
            @tds[x][y].setAttribute("class", "near-" + @near_mines[x][y])

    expand: (start_x, start_y) ->
        list = [[start_x, start_y]]
        while list.length > 0
            [x, y] = list.pop()
            @press(x, y)
            near_flags = 0
            # TODO count near flags
            if @near_mines[x][y] == near_flags
                for [nx, ny] in @near_positions(x, y)
                    td_class = @tds[nx][ny].getAttribute("class")
                    if td_class == null or td_class == ""
                        list.push([nx, ny])

    gameover: (x, y) ->
        # TODO

    stringify: ->
        JSON.stringify(@mines)

window.Minefield = Minefield