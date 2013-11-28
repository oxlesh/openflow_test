class LearningSwitch < Controller
  def start
    @fdb = {}
  end

  def packet_in(datapath_id, message)
    @fdb[message.macsa]=message.in_port
    port_no=@fdb[message.macda]
    if port_no
      flow_mod datapath_id, message, port_no
      packet_out datapath_id, message, port_no
    else
      flood datapath_id, message
    end
  end

  private

  def flow_mod(datapath_id, message, port_no)
    send_flow_mod_add(
      datapath_id,
      :match => ExactMatch.from(message),
      :actions => SendOutPort.new(port_no)
    )
  end

  def packet_out(datapath_id, message, port_no)
    send_packet_out(
      datapath_id,
      :packet_in => message,
      :actions => SendOutPort.new(port_no)
    )
  end

  def flood(datapath_id, message)
    packet_out datapath_id, message, OFPP_FLOOD
  end
end
