import { createChart, LineType } from "lightweight-charts";
import { createEffect, onMount, createSignal } from "solid-js";

export default function Chart(props: {
  data: any[];
  data2?: any[];
  suffix: string;
  id: string;
}) {
  function updateChart() {
    const div = document.getElementById(props.id)!;

    if (div) {
      div.innerHTML = "";

      const chart = createChart(div, {
        layout: {
          background: { color: "transparent" },
          textColor: "#fafafa",
          attributionLogo: false,
        },
        localization: {
          priceFormatter: (price) => {
            return `${price.toFixed(2)}${props.suffix}`;
          },
        },
        grid: {
          horzLines: { color: "#242424" },
          vertLines: { color: "#242424" },
        },
        timeScale: {
          borderColor: "#242424",
          timeVisible: true,
        },
        rightPriceScale: {
          borderColor: "#242424",
        },
      });

      const series = chart.addAreaSeries({
        lineType: LineType.Curved,
      });

      const sorted = props.data.sort((a, b) => {
        return a.time - b.time;
      });

      series.setData(sorted);

      if (props.data2) {
        const series2 = chart.addAreaSeries({
          lineType: LineType.Curved,
          lineColor: "#3b82f6",
          topColor: "rgba(59, 130, 246, 0.4)",
          bottomColor: "rgba(59, 130, 246, 0)",
        });

        const sorted2 = props.data2.sort((a, b) => {
          return a.time - b.time;
        });

        series2.setData(sorted2);
      }

      chart.timeScale().fitContent();
      console.log("chart", chart);
    }
  }

  createEffect(() => {
    const div = document.getElementById(props.id)!;

    if (div) {
      updateChart();
    }
  });

  onMount(() => {
    updateChart();
  });

  return <div id={props.id} class="size-full"></div>;
}
