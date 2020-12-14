# Vertex Finder

Firmware for Vertex finding in the CMS Level 1 Trigger Phase II Upgrade, built using RUFL components.

## emp-fwk project
<details>
<summary>One time emp-fwk setup</summary>
Install ipbb:
`pip install https://github.com/ipbus/ipbb/archive/v0.5.2.tar.gz`
Setup ipbb work area, with emp-fwk components:
```
mkdir p2fwk-work # can be named as you wish.
cd p2fwk-work/
ipbb init .
cd src/
git clone https://gitlab.cern.ch/p2-xware/firmware/emp-fwk -b v0.3.6
git clone https://gitlab.cern.ch/ttc/legacy_ttc -b v2.1
git clone https://github.com/ipbus/ipbus-firmware -b v1.8
```
</details>

For VCU118:
```
ipbb proj create vivado vxf_vcu118 VertexFinder: -t top_vcu118.dep
cd proj/vxf_vcu118
ipbb vivado project -c
ipbb vivado synth -j8 impl -j8 package
```

For Serenity KU115 SO1:
```
ipbb proj create vivado vxf_vcu118 VertexFinder: -t top_vcu118.dep
cd proj/vxf_vcu118
ipbb vivado project -c
ipbb vivado synth -j8 impl -j8 package
```

## Standalone simulation
View readme in `testbench/` directory.
