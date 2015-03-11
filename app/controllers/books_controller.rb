class BooksController < ApplicationController
	before_action :logged_in_school

	def index
		@books = current_school.books.joins(:usages).order("usages.form").paginate(:page => params[:page])
	end

	def new
		@book = Book.new
	end

	def create
		if (b = current_school.books.find_by(:isbn => params[:book][:isbn]))
			flash_message :notice, "Die Schule benutzt das Buch #{display_title(b)} bereits"
			redirect_to books_url
		elsif (b = Book.find_by(:isbn => params[:book][:isbn]))
			u = current_school.usages.new(:book => b, :form => params[:form])
			if u.save
				flash_message :success, "Buch erfolgreich hinzugefügt"
				redirect_to books_url
			else
				render "new"
			end
		else
			b = Book.new(params.require(:book).permit(:isbn, :title))
			if b.save
				flash_message :success, "Buch erfolgreich erstellt"
			else
				render "new"
			end
			u = current_school.usages.new(:book => b, :form => params[:form])
			if u.save
				flash_message :success, "Buch erfolgreich hinzugefügt"
				redirect_to books_url
			else
				render "new"
			end
		end
	end

	def destroy
		usage = current_school.usages.find_by(:book_id => params[:id])
		book = Book.find(params.require(:id))
		if not (usage and book)
			flash_message :danger, "Das Buch konnte nicht gefunden werden"
			redirect_to books_url
		end
		if usage.destroy
			flash_message :success, "Das Buch wurde erfolgreich entfernt"
		else
			flash_message :danger, "Das Buch konnte nicht entfernt werden"
			redirect_to books_url
		end
		if not Usage.exists?(:book_id => params[:id])
			if book.destroy
				flash_message :success, "Das Buch wurde erfolgreich gelöscht"
			else
				flash_message :danger, "Das Buch konnte nicht gelöscht werden"
				redirect_to books_url
			end
		end
		redirect_to books_url
	end

	def lookup
		@book = book_lookup(params[:b])
		@field = params[:a]
		respond_to do |format|
			format.js
		end
	end
end
