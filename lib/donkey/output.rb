require 'command_line_reporter'

module Donkey
	module Output
		class Printer
			def initialize options = {}
				@headers = {}
				@rows = []
				@printer = select_printer(options[:output])
			end

			def print options = {}
				options[:headers] = true if options[:headers] == nil
				@printer.print @headers, @rows, options
			end

			def add_header name, options = {}
				options[:width] ||= name.length
				@headers.merge!({ name.to_sym => options })
			end

			def add_row 
				@row = {}
				yield
				@rows << @row
				@headers.each do |k,v|
					v[:width] = max @row[k][:value].to_s.length, v[:width] if @row.has_key? k
				end
			end

			def add_column name, value, options = {}
				@row.merge!(create_row name, value, options)
			end

			private

			def select_printer type
				case type
				when :csv
					Donkey::Output::CSVPrinter.new
				else
					Donkey::Output::TablePrinter.new
				end
			end

			def create_row name, value, options = {}
				{ name.to_sym => { :value => value, :options => options } }
			end

			def max *values
				values.max
			end
		end

		class TablePrinter
			include CommandLineReporter

			def print headers, rows, options = {}
				options[:padding] ||= 3
				options[:nil] ||= "-"
				options[:border] ||= false
				options[:headers] = true if options[:headers] == nil

				table(:border => options[:border]) do
					
					row :header => true do
						headers.each do |k, v|
							v[:width] = v[:width] + options[:padding]
							column k, v 
						end
					end

					rows.each do |r|
						row do
							headers.each do |k, h|
								if r.has_key? k
									r[k] = {k => {:value => options[:nil]}} if r[k].nil?

									if r[k][:value].nil? or r[k][:value].to_s.empty?
										r[k][:value] = options[:nil]
									end

									column r[k][:value], r[k][:options] || {}
								else
									column options[:nil]
								end
							end
						end
					end
				end	
			end
		end

		class CSVPrinter
			def print headers, rows, options = {}
				options[:nil] ||= ""
				
				puts headers.keys.join(",") if options[:headers]

				rows.each do |r|
					values = headers.map do |k, h|
						if r.has_key? k
							r[k] = {k => {:value => options[:nil]}} if r[k].nil?

							if r[k][:value].nil? or r[k][:value].to_s.empty?
								r[k][:value] = options[:nil]
							end

							r[k][:value]
						else
							options[:nil]
						end
					end

					puts values.join(",")
				end
			end
		end
	end
end

