$ ->

    GRID_DIM = 5   # Size of grid squares
    RAND_THRESHOLD = .5 # Fraction of cells living at start
    COLOR_LIVE = 'rgb(0, 0, 0)'   # Fill color of live cells
    COLOR_DEAD = 'rgb(200, 200, 200)'   # Fill color of dead cells
    INTERVAL = 100  # Interval between simulation steps (ms)

    canvas = $ '#canvas'
    ctx = canvas[0].getContext '2d'
    running = null
    cells = []

    # Event handlers
    $('#step').click -> step()
    $('#run').click ->
        if running == null
            $(@).text 'Stop'
            $('#step').attr 'disabled', 'disabled'
            running = setInterval step, INTERVAL
        else
            $(@).text 'Run'
            clearInterval running
            $('#step').removeAttr 'disabled'
            running = null
    $('#randomize').click -> randomize()
    $('#clear').click ->
        clear()
        $('#run').click() if running
    canvas.click (e) ->
        x = Math.floor (e.pageX - canvas.offset().left) / GRID_DIM
        y = Math.floor (e.pageY - canvas.offset().top) / GRID_DIM
        cells[x][y] = not cells[x][y]
        renderCell x, y, cells[x][y]

    # Compute dimensions
    w_sq = Math.floor canvas.width() / GRID_DIM
    w_px = w_sq * GRID_DIM
    h_sq = Math.floor canvas.height() / GRID_DIM
    h_px = h_sq * GRID_DIM

    # Render cell liveness
    renderCell = (x, y, live) ->
        ctx.fillStyle = if live then COLOR_LIVE else COLOR_DEAD
        ctx.fillRect x * GRID_DIM, y * GRID_DIM, GRID_DIM - 1, GRID_DIM - 1

    # Randomize cells array & init grid
    randomize = ->
        for x in [0...w_sq]
            cells[x] = []
            for y in [0...h_sq]
                cells[x][y] = Math.random() < RAND_THRESHOLD
                renderCell x, y, cells[x][y]

    randomize()

    # Clear grid
    clear = ->
        for x in [0...w_sq]
            for y in [0...h_sq]
                cells[x][y] = false
                renderCell x, y, false

    # Get number of living neighbors
    liveNeighbors = (x, y) ->
        n = 0
        for nx in [x - 1, x, x + 1]
            for ny in [y - 1, y, y + 1]
                if 0 <= nx < w_sq and 0 <= ny < h_sq and cells[nx][ny] and not \
                (nx == x and ny == y)
                    ++n
        return n

    # Run 1 step of the simulation
    step = ->
        next_cells = []
        for x in [0...w_sq]
            next_cells[x] = []
            for y in [0...h_sq]
                
                ln = liveNeighbors x, y

                # Live
                if cells[x][y]
                    next_cells[x][y] = 2 <= ln <= 3

                # Dead
                else
                    next_cells[x][y] = ln == 3

                if next_cells[x][y] != cells[x][y]
                    renderCell x, y, next_cells[x][y]

        cells = next_cells
