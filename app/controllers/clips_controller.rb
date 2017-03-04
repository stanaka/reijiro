class ClipsController < ApplicationController
  def index
    @words = Word.joins(:clip).where('status != 8').order('updated_at DESC').page params[:page]
    @list_title = "Clipped words"

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @clips }
    end
  end

  def unknown
    @words = Word.joins(:clip).where('status = 1').order('updated_at DESC').page(params[:page])
    @list_title = "Clipped unknown words"
    render 'index'
  end

  def stagnate
    @words = Word.find_by_sql("SELECT words.*
    FROM checks
    INNER JOIN words ON checks.word_id = words.id
    WHERE (newstat = 1 or oldstat >= newstat)
    ORDER BY checks.updated_at DESC
    LIMIT 100 OFFSET 0;
    ");
    @list_title = "Clipped unknown words"
    render 'index'
  end


  def all
    @words = Word.joins(:clip).order('updated_at DESC')
    @list_title = "All clips"
  end

  def next
    @clip = Clip.next_clip
    if @clip
      @word = @clip.word
      render template: 'words/show'
    else
      redirect_to levels_path, notice: "No more items to review. Want to clip a little more words?"
    end
  end

  def nextup
    @words = Clip.next_list.page params[:page]
    @list_title = "Words to review"
    render 'index'
  end

  def update
    @clip = Clip.find(params[:id])
    @clip.touch # touch the record, even if there's no change

    Check.create({word_id: @clip.word.id, oldstat: @clip.status, newstat: params[:clip]['status']})

    respond_to do |format|
      if @clip.update_attributes(params[:clip])
        format.html { redirect_to @clip, notice: 'Clip was successfully updated.' }
        format.json { render json: @clip }
      else
        format.html { render action: "edit" }
        format.json { render json: @clip.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @clip = Clip.find(params[:id])
    @clip.destroy

    respond_to do |format|
      format.html { redirect_to clips_url }
      format.json { head :no_content }
    end
  end

  def stats
    @check_days = Check.check_days
    @check_months = {}
    @check_days.each { |cd|
      m = cd.date[0,7]
      @check_months[m] ||= { :new_count => 0, :all_count => 0, :up_count => 0, :done_count => 0 }
      @check_months[m][:new_count] +=cd.new_count
      @check_months[m][:up_count] +=cd.up_count
      @check_months[m][:done_count] +=cd.done_count
      @check_months[m][:all_count] +=cd.all_count
    }

    @stats = Clip.stats

    respond_to do |format|
      format.html
      format.json { render json: @stats }
    end
  end
end
