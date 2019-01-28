rule canvas_wgs_somatic:
    input: normal=lambda wildcards: config['project']['pairs'][wildcards.x][0]+".recal.bam",
           tumor=lambda wildcards: config['project']['pairs'][wildcards.x][1]+".recal.bam",
           somaticvcf=config['project']['workpath']+"/mutect2_out/{x}.FINALmutect2.vcf",
           index1=lambda wildcards: config['project']['pairs'][wildcards.x][0]+".recal.bai",
           index2=lambda wildcards: config['project']['pairs'][wildcards.x][1]+".recal.bai",
    output: tumorvcf="canvas_out/{x}/tumor_CNV.vcf.gz",
            normvcf="canvas_out/{x}/normal_CNV.vcf.gz",
    params: genome=config['references'][pfamily]['CANVASGENOME'],tumorsample=lambda wildcards: config['project']['pairs'][wildcards.x][1],normalsample=lambda wildcards: config['project']['pairs'][wildcards.x][0],kmer=config['references'][pfamily]['CANVASKMER'],filter=config['references'][pfamily]['CANVASFILTER'],balleles=config['references'][pfamily]['CANVASBALLELES'],ploidyvcf=config['references'][pfamily]['CANVASPLOIDY'],rname="pl:canvas"
    shell: "mkdir -p canvas_out; mkdir -p canvas_out/{params.normalsample}+{params.tumorsample}/{params.tumorsample}; mkdir -p canvas_out/{params.normalsample}+{params.tumorsample}/{params.normalsample}; cp {params.ploidyvcf} canvas_out/{params.normalsample}+{params.tumorsample}/{params.normalsample}/; cp {params.ploidyvcf} canvas_out/{params.normalsample}+{params.tumorsample}/{params.tumorsample}/; sed -i 's/SAMPLENAME/{params.tumorsample}/g' canvas_out/{params.normalsample}+{params.tumorsample}/{params.tumorsample}/ploidy.vcf; sed -i 's/SAMPLENAME/{params.normalsample}/g' canvas_out/{params.normalsample}+{params.tumorsample}/{params.normalsample}/ploidy.vcf; export COMPlus_gcAllowVeryLargeObjects=1; module load Canvas/1.38; Canvas.dll Somatic-WGS -b {input.tumor} -o canvas_out/{params.normalsample}+{params.tumorsample}/{params.tumorsample} -n {params.tumorsample} -r {params.kmer} -g {params.genome} -f {params.filter} --population-b-allele-vcf={params.balleles} --somatic-vcf={input.somaticvcf} --ploidy-vcf=canvas_out/{params.normalsample}+{params.tumorsample}/{params.tumorsample}/ploidy.vcf; Canvas.dll Germline-WGS -b {input.normal} -o canvas_out/{params.normalsample}+{params.tumorsample}/{params.normalsample} -r {params.kmer} -g {params.genome} -f {params.filter} -n {params.normalsample} --population-b-allele-vcf={params.balleles} --ploidy-vcf=canvas_out/{params.normalsample}+{params.tumorsample}/{params.normalsample}/ploidy.vcf; mv canvas_out/{params.normalsample}+{params.tumorsample}/{params.tumorsample}/CNV.vcf.gz canvas_out/{params.normalsample}+{params.tumorsample}/tumor_CNV.vcf.gz; mv canvas_out/{params.normalsample}+{params.tumorsample}/{params.normalsample}/CNV.vcf.gz canvas_out/{params.normalsample}+{params.tumorsample}/normal_CNV.vcf.gz"