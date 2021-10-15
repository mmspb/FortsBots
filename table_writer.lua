
-- Clean things up
function OnStop(s)
	stopped = true
end

 math.round = function(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

-- Entry point
function main()

 tbl = {  }
 tbl["Si"] = "<i class='bi bi-currency-exchange'></i>&nbsp;&nbsp;&nbsp;"
 tbl["RI"] = "<i class='bi bi-bank'></i>&nbsp;&nbsp;&nbsp;"
 tbl["MX"] = "<i class='bi bi-bank'></i>&nbsp;&nbsp;&nbsp;"
 tbl["GZ"] = "<i style='color:blue' class='bi bi-cone-striped'></i>&nbsp;&nbsp;&nbsp;"
 tbl["SR"] = "<i style='color:green' class='bi bi-cash-stack'></i>&nbsp;&nbsp;&nbsp;" 
 tbl["SF"] = "<i class='bi bi-bank'></i>&nbsp;&nbsp;&nbsp;"
 tbl["GD"] = "<i style='color:gold' class='bi bi-bricks'></i>&nbsp;&nbsp;&nbsp;"
 tbl["SV"] = "<i style='color:silver' class='bi bi-bricks'></i>&nbsp;&nbsp;&nbsp;" 
 tbl["BR"] = "<i class='bi bi-droplet-fill'></i>&nbsp;&nbsp;&nbsp;"
 tbl["NG"] = "<i class='bi bi-clouds'></i>&nbsp;&nbsp;&nbsp;"

 
 -- Codes = {"SiZ1","RIZ1","MXZ1","SFZ1","GZZ1","SRZ1","GDZ1","SVZ1","BRX1","BRZ1","NGX1","NGV1","NGZ1"}
 Codes = {"SiZ1","BRX1","BRZ1"}
 
 Stocks = {"ENPG","ETLN","FIXP","GLTR","MAIL","OKEY","OZON","POGR","POLY","QIWI","TCSG","GEMC","YNDX","ABRD","AKRN","ALRS","ALNU","APTK","AFKS","AMEZ","AFLT","VTBR","BSPB","BANE","BANEP","BELU","VSMO","OGKB","GAZP","SIBN","FIVE","MDMG","SMLT","GRNT","LSRG","GCHE","GTRK","DASB","FESH","DSKY","DVEC","IRAO","IRGZ","ISKJ","KLSB","KMAZ","TGKD","KROT","KBTK","LNZL","LNZLP","LNTA","LSNG","LSNGP","LKOH","MVID","MGNT","MAGN","MGTSP","MTLR","MTLRP","CBOM","MOEX","MSNG","MSRS","MRKV","MRKZ","MRKS","MRKU","MRKC","MRKP","MRKY","MTSS","MSST","NSVZ","NKNC","NKNCP","NKHP","NLMK","NMTP","NVTK","GMKN","ORUP","UWGN","KZOS","KZOSP","PMSB","PMSBP","PIKK","PLZL","RASP","RKKE","ROSN","RSTI","RSTIP","RTKM","RTKMP","AGRO","RUAL","HYDR","RUGR","ROLO","RUSP","AQUA","RNFT","KRKNP","SBER","SBERP","CHMF","SGZH","SELG","SELGP","FLOT","SVAV","SNGS","SNGSP","TATN","TATNP","TTLK","TGKA","TGKN","TGKB","TGKBP","VRSB","TRNFP","TRMK","LIFE","PHOR","FEES","CNTL","CNTLP","PRFN","CHMK","CHEP","ENRU","SFIN","UPRO","UNKL"}
 
 local FilePNL = "C:\\wamp64\\www\\pnl.csv"
 local FileName = "C:\\wamp64\\www\\test.csv"
 local FileNameSt = "C:\\wamp64\\www\\stocks.csv"
 local FilePositions = "C:\\wamp64\\www\\positions.csv"
 
	 while not stopped do 
		data = ""
		datast = ""
		pos = ""
		for i = 1, #Codes, 1 do 	
			name = getParamEx("SPBFUT",  Codes[i], "SHORTNAME")
			bids = getParamEx("SPBFUT", Codes[i], "NUMBIDS")
			offers = getParamEx("SPBFUT", Codes[i], "NUMOFFERS")
			last = getParamEx("SPBFUT", Codes[i], "LAST")
			
			denominator = math.min(bids.param_value, offers.param_value)
			
			power = math.round((bids.param_value  - offers.param_value) / denominator * 100,0)
			key = string.sub(Codes[i],1,2)
			if(power < 0) then
				col = "danger"
				col2 = "red"
				act = "Short"			
			else
				col = "success"		
				col2 = "green"
				act = "Long"
			end; 
			ending = ""
            if i < #Codes  then											
			    ending = "\n"
			end; 
			data = data..tbl[key].." <b>"..tostring(Codes[i]).."<b>,<b>"..tonumber(last.param_value).."</b>,"..math.floor(bids.param_value)..","..math.floor(offers.param_value,0)..",<b><span style='color:"..col2.."'>"..act.." "..
			math.floor(math.abs(power)).."%</span><b>,<div class='progress'><div class='progress-bar bg-"..col.."' role='progressbar' style='width: "..math.floor(math.abs(power)).."%;' aria-valuenow='"..power.."' aria-valuemin='0' aria-valuemax='100'></div></div>"..ending
		end;
		
		FW = io.open(FileName, "w")
			if FW ~=nil then
				FW:write(data)
				FW:close()
			end;    	
		
		for i = 1, #Stocks, 1 do 	
			name = getParamEx("TQBR",  Stocks[i], "SHORTNAME")
			bids = getParamEx("TQBR", Stocks[i], "NUMBIDS")
			offers = getParamEx("TQBR", Stocks[i], "NUMOFFERS")
			last = getParamEx("TQBR", Stocks[i], "LAST")
			power = math.round((bids.param_value  - offers.param_value) / bids.param_value * 100,0)
			key = string.sub(Stocks[i],1,2)
			if(power < 0) then
				col = "danger"
				col2 = "red"
				act = "Short"			
			else
				col = "success"		
				col2 = "green"
				act = "Long"
			end;
			datast = datast.."<img width='25%' src='/images/"..tostring(Stocks[i])..".png'>&nbsp;&nbsp;<b>"..tostring(Stocks[i]).."<b>,<b>"..tonumber(last.param_value).."</b>,"..math.floor(bids.param_value)..","..math.floor(offers.param_value,0)..",<b><span style='color:"..col2.."'>"..act.." "..
			math.floor(math.abs(power)).."%</span><b>,<div class='progress'><div class='progress-bar bg-"..col.."' role='progressbar' style='width: "..math.floor(math.abs(power)).."%;' aria-valuenow='"..power.."' aria-valuemin='0' aria-valuemax='100'></div></div>".."\n"
		end;
		
		FW = io.open(FileNameSt, "w")
			if FW ~=nil then
				FW:write(datast)
				FW:close()
			end;   
			   

		if getItem("futures_client_limits",0) == nil then
		 break;
		end;
		
        pnl = 0		
		fee = getItem("futures_client_limits",0).ts_comission 		
		
		
		
		for i = 0,getNumberOf("FUTURES_CLIENT_HOLDING") - 1 do
		   if getItem("FUTURES_CLIENT_HOLDING",i).totalnet ~= 0 then
				totalNet = getItem("FUTURES_CLIENT_HOLDING",i).totalnet
				secCode = getItem("FUTURES_CLIENT_HOLDING",i).sec_code
			    varMargin  = getItem("FUTURES_CLIENT_HOLDING",i).varmargin  
				avgPos = getItem("FUTURES_CLIENT_HOLDING",i).avrposnprice		
			    lastQ = getParamEx("SPBFUT", secCode, "LAST").param_value		

				if(varMargin < 0) then
					col2 = "red"								
				 else							
					col2 = "green"						
				end;
		    ending = ""
            if i < getNumberOf("FUTURES_CLIENT_HOLDING") - 1  then											
			    ending = "\n"
			end; 
			    key = string.sub(secCode,1,2)
		        pos = pos..tbl[key].."<b>"..secCode.."</b>,<b>"..avgPos.."</b>,<b>"..tonumber(lastQ).."</b>,<b>"..totalNet.."</span></b>,<b><span style='color:"..col2.."'>"..varMargin.."<b>"..ending
          	    pnl = pnl + varMargin
			
		   end;
		end;
		     if(pnl < 0) then
					col2 = "red"								
				 else							
					col2 = "green"						
				end;
		 pos = pos.. "\n,<b>Fee:</b>,<b>"..fee.."</b>,<b>Total:</b>,<b><span style='color:"..col2.."'>"..pnl.."<b>"
					
					
		FW = io.open(FilePositions, "w")
			if FW ~=nil then
				FW:write(pos)
				FW:close()
			end;   
			
		FW = io.open(FilePNL, "w")
			if FW ~=nil then
				FW:write(pnl)
				FW:close()
			end; 
			
		sleep(1000);
	end 
end
