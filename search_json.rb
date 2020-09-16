require 'json'
require 'minitest/autorun'

class SearchJson
  FIELD_NAMES = %w[Name Type Designed Scripting Created].freeze

  def search(search_value)
    lines = read_file
    result = []

    lines.each do |line|
      values = line.values
      words = []

      # splitting into words
      values.each { |value| words += value.split(' ') }

      # splitting search value to check different position of them
      search_words = search_value.split(' ')

      # check that we have field names in our search
      if search_words.any? {|x| FIELD_NAMES.include?(x) }
        search_result = search_by_field(line, search_value)
        result << search_result if search_result
      end

      # check that we have all search words in our lines
      if (words & search_words).size == search_words.size
        result << line.to_json
      end
    end

    result
  end

  private

  def read_file
    content = File.read('data.json')
    JSON.parse(content)
  end

  # method searching data from field
  def search_by_field(line, search_value)
    words = search_value.split(' ')

    # giving fields true names form json
    true_name = if %w[Designed Scripting Created].include? words.first
                  "Designed by"
                  else words.first
                end

    words.delete_at(0)
    if line[true_name] == words.join(' ')
      line.to_json
    end
  end
end



class SearchJsonTest < Minitest::Test
  def setup
    @search_json = SearchJson.new
  end

  def test_search_json_one_result
    actual = @search_json.search('Visual FoxPro')
    expected = ["{\"Name\":\"Visual FoxPro\",\"Type\":\"Compiled, Data-oriented, Object-oriented class-based, Procedural\",\"Designed by\":\"Microsoft\"}"]
    assert_equal(expected, actual)
  end

  def test_search_json_many_results
    actual = @search_json.search('Array')
    expected = ["{\"Name\":\"A+\",\"Type\":\"Array\",\"Designed by\":\"Arthur Whitney\"}", "{\"Name\":\"Chapel\",\"Type\":\"Array\",\"Designed by\":\"David Callahan, Hans Zima, Brad Chamberlain, John Plevyak\"}", "{\"Name\":\"K\",\"Type\":\"Array\",\"Designed by\":\"Arthur Whitney\"}", "{\"Name\":\"S\",\"Type\":\"Array\",\"Designed by\":\"Rick Becker, Allan Wilks, John Chambers\"}", "{\"Name\":\"ZPL\",\"Type\":\"Array\",\"Designed by\":\"Chamberlain\"}"]
    assert_equal(expected, actual)
  end

  def test_search_json_without_order
    actual = @search_json.search('Lisp Common')
    expected = ["{\"Name\":\"Common Lisp\",\"Type\":\"Compiled, Interactive mode, Object-oriented class-based, Reflective\",\"Designed by\":\"Scott Fahlman, Richard P. Gabriel, Dave Moon, Guy Steele, Dan Weinreb\"}"]
    assert_equal(expected, actual)
  end

  def test_search_json_exact_matches
    actual = @search_json.search("Interpreted Thomas Eugene")
    expected = ["{\"Name\":\"BASIC\",\"Type\":\"Imperative, Compiled, Procedural, Interactive mode, Interpreted\",\"Designed by\":\"John George Kemeny, Thomas Eugene Kurtz\"}"]
    assert_equal(expected, actual)
  end

  def test_search_json_no_matches
    actual = @search_json.search("Test test")
    expected = []
    assert_equal(expected, actual)
  end

  def test_search_json_no_exact_matches
    actual = @search_json.search("PowerShell Object-oriented")
    expected = []
    assert_equal(expected, actual)
  end

  def test_search_json_scripting
    actual = @search_json.search("Scripting Microsoft")
    expected = ["{\"Name\":\"C#\",\"Type\":\"Compiled, Curly-bracket, Iterative, Object-oriented class-based, Reflective, Procedural\",\"Designed by\":\"Microsoft\"}", "{\"Name\":\"JScript\",\"Type\":\"Curly-bracket, Procedural, Reflective, Scripting\",\"Designed by\":\"Microsoft\"}", "{\"Name\":\"JScript\",\"Type\":\"Curly-bracket, Procedural, Reflective, Scripting\",\"Designed by\":\"Microsoft\"}", "{\"Name\":\"VBScript\",\"Type\":\"Interpreted, Procedural, Scripting, Object-oriented class-based\",\"Designed by\":\"Microsoft\"}", "{\"Name\":\"Visual Basic\",\"Type\":\"Compiled, Procedural\",\"Designed by\":\"Microsoft\"}", "{\"Name\":\"Visual FoxPro\",\"Type\":\"Compiled, Data-oriented, Object-oriented class-based, Procedural\",\"Designed by\":\"Microsoft\"}", "{\"Name\":\"Windows PowerShell\",\"Type\":\"Command line interface, Curly-bracket, Interactive mode, Interpreted, Scripting\",\"Designed by\":\"Microsoft\"}", "{\"Name\":\"Windows PowerShell\",\"Type\":\"Command line interface, Curly-bracket, Interactive mode, Interpreted, Scripting\",\"Designed by\":\"Microsoft\"}", "{\"Name\":\"X++\",\"Type\":\"Compiled, Object-oriented class-based, Procedural, Reflective\",\"Designed by\":\"Microsoft\"}"]
    assert_equal(expected, actual)
  end

  def test_search_json_long_name_scripting
    actual = @search_json.search("Designed Christophe de Dinechin")
    expected = ["{\"Name\":\"XL\",\"Type\":\"Compiled, Procedural, Reflective, Iterative, Metaprogramming\",\"Designed by\":\"Christophe de Dinechin\"}"]
    assert_equal(expected, actual)
  end

  def test_search_json_name
    actual = @search_json.search("Name Visual Basic")
    expected = ["{\"Name\":\"Visual Basic\",\"Type\":\"Compiled, Procedural\",\"Designed by\":\"Microsoft\"}"]
    assert_equal(expected, actual)
  end
end