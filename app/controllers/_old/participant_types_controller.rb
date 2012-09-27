class ParticipantTypesController < ApplicationController
  # GET /participant_types
  # GET /participant_types.json
  def index
    @participant_types = ParticipantType.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @participant_types }
    end
  end

  # GET /participant_types/1
  # GET /participant_types/1.json
  def show
    @participant_type = ParticipantType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @participant_type }
    end
  end

  # GET /participant_types/new
  # GET /participant_types/new.json
  def new
    @participant_type = ParticipantType.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @participant_type }
    end
  end

  # GET /participant_types/1/edit
  def edit
    @participant_type = ParticipantType.find(params[:id])
  end

  # POST /participant_types
  # POST /participant_types.json
  def create
    @participant_type = ParticipantType.new(params[:participant_type])

    respond_to do |format|
      if @participant_type.save
        format.html { redirect_to @participant_type, notice: 'Participant type was successfully created.' }
        format.json { render json: @participant_type, status: :created, location: @participant_type }
      else
        format.html { render action: "new" }
        format.json { render json: @participant_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /participant_types/1
  # PUT /participant_types/1.json
  def update
    @participant_type = ParticipantType.find(params[:id])

    respond_to do |format|
      if @participant_type.update_attributes(params[:participant_type])
        format.html { redirect_to @participant_type, notice: 'Participant type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @participant_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /participant_types/1
  # DELETE /participant_types/1.json
  def destroy
    @participant_type = ParticipantType.find(params[:id])
    @participant_type.destroy

    respond_to do |format|
      format.html { redirect_to participant_types_url }
      format.json { head :no_content }
    end
  end
end
