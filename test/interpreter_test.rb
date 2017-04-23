require_relative 'test_helper.rb'
require_src 'interpreter.rb'

describe Interpreter do
  let(:interpreter) { Interpreter.new }

  describe '#eval' do
    let(:expression) { 'nil' }

    describe 'when expression is nil' do
      it 'should return nil' do
        assert_nil interpreter.eval(expression)
      end
    end

    describe 'builtins' do
      describe 'binary operators' do
        let(:operator) { '+' }
        let(:args) { [1, 2, 3] }
        let(:expression) { "(#{operator} #{args.join(' ')})" }
        let(:result) { 6 }

        def error_message(too_many = false)
          keyword = too_many ? 'many' : 'few'
          "Error: Too #{keyword} arguments given to #{operator}"
        end

        describe 'addition' do
          describe 'when there are arguments' do
            it 'should add all the arguments' do
              assert_equal interpreter.eval(expression), result
            end
          end

          describe 'when there are no arguments' do
            let(:args) { [] }
            let(:result) { 0 }

            it 'should return 0' do
              assert_equal interpreter.eval(expression), result
            end
          end
        end

        describe 'subtraction' do
          let(:operator) { '-' }
          let(:result) { -4 }

          describe 'when there are arguments' do
            it 'should subtract all the arguments' do
              assert_equal interpreter.eval(expression), result
            end
          end

          describe 'when there are no arguments' do
            let(:args) { [] }

            it 'should print error to STDERR' do
              assert_output(nil, /#{error_message}/) { interpreter.eval(expression) }
            end

            it 'should return nil' do
              assert_nil interpreter.eval(expression)
            end
          end

          describe 'when there is one argument' do
            let(:result) { 4 }
            let(:args) { [result] }

            it 'returns the argument' do
              assert_equal interpreter.eval(expression), result
            end
          end
        end

        describe 'muliplication' do
          let(:operator) { '*' }
          let(:result) { 6 }

          describe 'when there are arguments' do
            it 'should multiply all the arguments' do
              assert_equal interpreter.eval(expression), result
            end
          end

          describe 'when there are no arguments' do
            let(:args) { [] }
            let(:result) { 1 }
            
            it 'should return 1' do
              assert_equal interpreter.eval(expression), result
            end
          end
        end

        describe 'division' do
          let(:operator) { '/' }
          let(:args) { [9, 3] }
          let(:result) { 3 }

          describe 'when there are arguments' do
            it 'should divide all the arguments' do
              assert_equal interpreter.eval(expression), result
            end
          end

          describe 'when there are no arguments' do
            let(:args) { [] }

            it 'should print error to STDERR' do
              assert_output(nil, /#{error_message}/) { interpreter.eval(expression) }
            end

            it 'should return nil' do
              assert_nil interpreter.eval(expression)
            end
          end

          describe 'when there is one argument' do
            let(:result) { 4 }
            let(:args) { [result] }

            it 'returns the argument' do
              assert_equal interpreter.eval(expression), result
            end
          end
        end

        describe 'modulus' do
          let(:operator) { '%' }
          let(:args) { [10, 3] }
          let(:result) { 1 }

          describe 'when there are two arguments' do
            it 'should divide all the arguments' do
              assert_equal interpreter.eval(expression), result
            end
          end

          describe 'when there are no arguments' do
            let(:args) { [] }

            it 'should print error to STDERR' do
              assert_output(nil, /#{error_message}/) { interpreter.eval(expression) }
            end

            it 'should return nil' do
              assert_nil interpreter.eval(expression)
            end
          end
        end

        describe 'exponent' do
          let(:operator) { '**' }
          let(:args) { [2, 4] }
          let(:result) { 16 }

          describe 'when there are arguments' do
            it 'should divide all the arguments' do
              assert_equal interpreter.eval(expression), result
            end
          end

          describe 'when there are no arguments' do
            let(:args) { [] }

            it 'should print error to STDERR' do
              assert_output(nil, /#{error_message}/) { interpreter.eval(expression) }
            end

            it 'should return nil' do
              assert_nil interpreter.eval(expression)
            end
          end

          describe 'when there is one argument' do
            let(:result) { 4 }
            let(:args) { [result] }

            it 'returns the argument' do
              assert_equal interpreter.eval(expression), result
            end
          end
        end

        describe 'equal to' do
          let(:operator) { '==' }
          let(:args) { [1, 1] }

          describe 'when there are arguments' do
            describe 'when they are equal' do
              it 'should return true' do
                assert interpreter.eval(expression)
              end
            end

            describe 'when they are not equal' do
              let(:args) { [1, 2] }

              it 'should return false' do
                refute interpreter.eval(expression)
              end
            end
          end

          describe 'when there are no arguments' do
            let(:args) { [] }

            it 'should print error to STDERR' do
              assert_output(nil, /#{error_message}/) { interpreter.eval(expression) }
            end

            it 'should return nil' do
              assert_nil interpreter.eval(expression)
            end
          end
        end

        describe 'greater than' do
          let(:operator) { '>' }
          let(:args) { [2, 1] }

          describe 'when there are two arguments' do
            describe 'when a is greater than b' do
              it 'should return true' do
                assert interpreter.eval(expression)
              end
            end

            describe 'when a is not greater than b' do
              let(:args) { [1, 2] }

              it 'should return false' do
                refute interpreter.eval(expression)
              end
            end
          end

          describe 'when there are no arguments' do
            let(:args) { [] }

            it 'should print error to STDERR' do
              assert_output(nil, /#{error_message}/) { interpreter.eval(expression) }
            end

            it 'should return nil' do
              assert_nil interpreter.eval(expression)
            end
          end

          describe 'when there are too many arguments' do
            let(:args) { [1, 2, 3] }

            it 'should print error to STDERR' do
              assert_output(nil, /#{error_message(true)}/) { interpreter.eval(expression) }
            end

            it 'should return nil' do
              assert_nil interpreter.eval(expression)
            end
          end
        end

        describe 'less than' do
          let(:operator) { '<' }
          let(:args) { [1, 2] }

          describe 'when there are two arguments' do
            describe 'when a is less than b' do
              it 'should return true' do
                assert interpreter.eval(expression)
              end
            end

            describe 'when a is not less than b' do
              let(:args) { [2, 1] }

              it 'should return false' do
                refute interpreter.eval(expression)
              end
            end
          end

          describe 'when there are no arguments' do
            let(:args) { [] }

            it 'should print error to STDERR' do
              assert_output(nil, /#{error_message}/) { interpreter.eval(expression) }
            end

            it 'should return nil' do
              assert_nil interpreter.eval(expression)
            end
          end

          describe 'when there are too many arguments' do
            let(:args) { [1, 2, 3] }

            it 'should print error to STDERR' do
              assert_output(nil, /#{error_message(true)}/) { interpreter.eval(expression) }
            end

            it 'should return nil' do
              assert_nil interpreter.eval(expression)
            end
          end
        end

        describe 'greater than or equal to' do
          let(:operator) { '>=' }
          let(:args) { [2, 1] }

          describe 'when there are two arguments' do
            describe 'when a is greater than b' do
              it 'should return true' do
                assert interpreter.eval(expression)
              end
            end

            describe 'when a is equal to b' do
              let(:args) { [2, 2] }

              it 'should return true' do
                assert interpreter.eval(expression)
              end
            end

            describe 'when a is not greater than b' do
              let(:args) { [1, 2] }

              it 'should return false' do
                refute interpreter.eval(expression)
              end
            end
          end

          describe 'when there are no arguments' do
            let(:args) { [] }

            it 'should print error to STDERR' do
              assert_output(nil, /#{error_message}/) { interpreter.eval(expression) }
            end

            it 'should return nil' do
              assert_nil interpreter.eval(expression)
            end
          end

          describe 'when there are too many arguments' do
            let(:args) { [1, 2, 3] }

            it 'should print error to STDERR' do
              assert_output(nil, /#{error_message(true)}/) { interpreter.eval(expression) }
            end

            it 'should return nil' do
              assert_nil interpreter.eval(expression)
            end
          end
        end

        describe 'less than or equal to' do
          let(:operator) { '<=' }
          let(:args) { [1, 2] }

          describe 'when there are two arguments' do
            describe 'when a is less than b' do
              it 'should return true' do
                assert interpreter.eval(expression)
              end
            end

            describe 'when a is equal to b' do
              let(:args) { [2, 2] }

              it 'should return true' do
                assert interpreter.eval(expression)
              end
            end

            describe 'when a is not less than b' do
              let(:args) { [2, 1] }

              it 'should return false' do
                refute interpreter.eval(expression)
              end
            end
          end

          describe 'when there are no arguments' do
            let(:args) { [] }

            it 'should print error to STDERR' do
              assert_output(nil, /#{error_message}/) { interpreter.eval(expression) }
            end

            it 'should return nil' do
              assert_nil interpreter.eval(expression)
            end
          end

          describe 'when there are too many arguments' do
            let(:args) { [1, 2, 3] }

            it 'should print error to STDERR' do
              assert_output(nil, /#{error_message(true)}/) { interpreter.eval(expression) }
            end

            it 'should return nil' do
              assert_nil interpreter.eval(expression)
            end
          end
        end
      end
    end
  end
end
