.PHONY:clean sim verdi

OUTPUT = CortexM0_SoC_vlg_tst
VERDI_DIR = /home/synopsys/verdi/Verdi_O-2018.09-SP2/share/PLI/VCS/LINUX64
#SIM_TIME = 4000000 #3000ms

VCS = vcs -sverilog +v2k \
	-P ${VERDI_HOME}/share/PLI/VCS/LINUX64/novas.tab ${VERDI_HOME}/share/PLI/VCS/LINUX64/pli.a \
	-debug_acc+all \
	-debug_region+cell+encrypt \
	+notimingcheck \
	+nospecify \
	-timescale=1ns/1ns \
	+vcs+flush+all \
	-o ${OUTPUT} \
	-l compile.log \
	+lint=TFIPC-L \
	-R \
	-j2 \
	-full64 \
	-debug_pp +memcbk \


sim:
	${VCS} -f flist.f

verdi:
	verdi -sv -f flist.f -ssf ${OUTPUT}.fsdb -sswr ./signal.rc

clean:
	rm -rf ./csrc ./verdiLog ./*.vdb *.daidir *.log *.vpd simv* *.vdb *.key *race.out* *.fsdb *.fsdb.* *.conf novas* pic_adc

copy:
	cp ../../../wl-share/I2C/keil/code.hex ../keil/
	cp -r ../../../wl-share/I2C/rtl/ ../
	cp -r ../../../wl-share/I2C/vcs/_tb ./
	cp -r ../../../wl-share/I2C/vcs/flist.f ./


all: clean copy sim verdi
