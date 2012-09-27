class LabelsController < ApplicationController
  load_and_authorize_resource :label, :through => :current_user

  def create
    respond_to do |format|
      if @label.save
        format.html { redirect_to labels_path, notice: 'Label was successfully created.' }
        format.json { render json: labels_path, status: :created, location: @label }
      else
        format.html { render action: 'new' }
        format.json { render json: @label.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @label.update_attributes(params[:label])
        format.html { redirect_to labels_path, notice: 'Label was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action:'edit' }
        format.json { render json: @label.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @label.destroy

    respond_to do |format|
      format.html { redirect_to labels_path }
      format.json { head :no_content }
    end
  end
end
