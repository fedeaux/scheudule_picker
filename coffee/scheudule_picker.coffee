# This function must be somewhere else in production
@unique_id = (length=8) ->
  id = ""
  id += Math.random().toString(36).substr(2) while id.length < length
  id.substr 0, length

class @ScheudulePicker
  constructor: (selector) ->
    @input = $ selector
    @id = 'scheudule_picker_'+unique_id()

    @change_markup()
    

  change_markup: () ->
    #@input.hide()
    @input.after @create_selector()

  create_selector: () ->
    @selector = $ @create_selector_markup()
    @selector.click @show_picker
    @selector    

  create_selector_markup: () ->
    '<input type="button" class="scheudule_picker_selector" value="Select Scheudule" />'

  show_picker: () =>
    if @picker?
      @picker.fadeIn()
    else
      @create_picker()

  create_picker: () ->
    @picker = @create_picker_markup()
    @picker.hide()

    @selector.after @picker
    @check_for_previous_value()

    $('.scheudule_picker_add_row', @picker).click @add_row
    $('.scheudule_picker_ok', @picker).click @ok
    $('tbody', @picker).on 'click', '.scheudule_picker_remove_row', @remove_row

    @show_picker()

  check_for_previous_value: () ->
    prev_val = @input.val()
    try
      json = JSON.parse prev_val
      @val json

  remove_row: (e) ->
    $(e.target).parents('tr').remove()

  ok: () =>
    json = @get_json_values()
    @input.val json
    @picker.fadeOut()

  get_json_values: () =>
    JSON.stringify @val()

  val: (arg = null) =>
    if arg == null
      @get_value()
    else
      @set_value arg

  set_value: (value) ->
    for row in value
      @add_row_with_values row

  get_value: () ->
    val = []

    $('tbody tr', @picker).each () ->
      tr = $(this)

      row = {}
      row.time = $('input[data-scheudule-rel=time]', tr).val()
      row.days = []

      $('[type=checkbox]', tr).each () ->
        cb = $ this
        row.days.push cb.attr('data-scheudule-rel') if cb.is ':checked'

      val.push row
    val

  add_row: () =>
    $('tbody', @picker).append @create_row_markup()

  add_row_with_values: (values) =>
    $('tbody', @picker).append @create_row_markup values

  parse_row_markup_values: (values) ->
    ret =
      time: ''
      cb0: ''
      cb1: ''
      cb2: ''
      cb3: ''
      cb4: ''
      cb5: ''
      cb6: ''

    if values == null
      return ret

    ret.time = values.time
    for i in values.days
      ret['cb'+i] = 'checked="checked"'

    ret

  create_row_markup: (values = null) ->
    #Sunday is 0, Monday is 1, and so on.

    values = @parse_row_markup_values values

    html = '
    <tr>
      <td><input type="text" data-scheudule-rel="time" value="'+values.time+'" ></td>'

    for i in [0..6]
      html += '<td><input type="checkbox" '+values['cb'+i]+' data-scheudule-rel="'+i+'"/></td>'

    html += '
      <td><a href="#" class="scheudule_picker_remove_row"> remove </a></td>
    </tr>'

  create_picker_markup: () ->
    html = $ '<div class="scheudule_picker_wrapper" id="'+@id+'">
                <table>
                  <thead>
                    <tr>
                      <th></th>
                      <th>Sun</th>
                      <th>Mon</th>
                      <th>Tue</th>
                      <th>Wed</th>
                      <th>Thu</th>
                      <th>Fri</th>
                      <th>Sat</th>
                      <th></th>
                    </tr>
                  </thead>
                  <tbody>
                  </tbody>
                  <tfoot>
                    <tr>
                      <td>
                      </td>
                      <td colspan="7">
                        <input type="button" class="scheudule_picker_add_row" value="Add row" />
                      </td>
                      <td>
                        <input type="button" class="scheudule_picker_ok" value="Ok" />
                      </td>
                    </tr>
                  </tfoot>
                </table>
              </div>'
